pub mod data_types;

use mysql::prelude::*;
use mysql::*;
use std::collections::HashMap;
use std::env;

fn get_url() -> String {
    format!(
        "mysql://rust:rust-password@{}:3306/database",
        &env::var("DATABASE_HOSTNAME").unwrap()
    )
}

// Returns all distinct values from table as map[table_name: Vec[values]]
// If sum in demand while having this in where requirements is equal 0 this value is ignored
pub fn get_distinct_values(
    table: String,
    where_requirements: HashMap<&'_ str, &'_ str>,
) -> Result<Vec<data_types::Column>> {
    let where_stmt = create_where_statement(where_requirements);

    let pool = Pool::new(Opts::from_url(&get_url())?)?;
    let mut conn = pool.get_conn()?;
    let columns: Vec<String> = conn.query(format!(
        "
        select COLUMN_NAME 
        from INFORMATION_SCHEMA.COLUMNS 
        where 
            TABLE_SCHEMA = Database()
            and TABLE_NAME = '{}' 
        order by COLUMN_NAME desc;",
        &table
    ))?;

    let res: Vec<data_types::Column> = columns.iter().fold(Vec::new(), |mut vec, column| {
        println!(
            "
            select {} 
            from demand
            natural join product_groups 
            natural join country_groups
            {}
            group by {};",
            &column, &where_stmt, &column
        );
        vec.push(data_types::Column {
            name: column.clone(),
            values: conn
                .query::<String, String>(if where_stmt.is_empty() {
                    format!(
                        "
                    select distinct {}
                    from {}",
                        &column, &table
                    )
                } else {
                    format!(
                        "
                    select {} 
                    from demand
                    natural join product_groups 
                    natural join country_groups
                    {}
                    group by {};
                ",
                        &column, &where_stmt, &column
                    )
                })
                .unwrap(),
        });
        vec
    });

    Ok(res)
}

fn create_where_statement(where_requirements: HashMap<&'_ str, &'_ str>) -> String {
    let mut where_stmt = String::from("where");

    for (&column, &value) in &where_requirements {
        where_stmt += &format!(" {}='{}' and", column, value);
    }

    if where_stmt.ends_with("where") {
        where_stmt = String::new();
    } else if where_stmt.ends_with("and") {
        where_stmt.truncate(where_stmt.len() - 4);
    }

    where_stmt
}

pub fn get_sum(
    table: &'_ str,
    where_requirements: HashMap<&'_ str, &'_ str>,
) -> Result<data_types::DataSum> {
    let where_stmt = create_where_statement(where_requirements);

    let pool = Pool::new(Opts::from_url(&get_url())?)?;

    let mut conn = pool.get_conn()?;

    Ok(data_types::DataSum {
        values: conn.query_map(
            format!(
                "select
            month(month) as month,
            sum(value) as val
            from {}
            natural join products
            natural join product_groups
            natural join country_groups
            {} 
            group by month
            order by month
            ",
                &table, &where_stmt
            ),
            |mut row: Row| row.take("val").unwrap(),
        )?,
    })
}

pub fn get_data_cell(
    table: &'_ str,
    where_requirements: HashMap<&'_ str, &'_ str>,
) -> Result<Vec<data_types::DataRow>> {
    let fulfillable = (if table == "demand" {
        ", fulfillable"
    } else {
        ""
    })
    .to_string();

    let where_stmt = create_where_statement(where_requirements);

    let pool = Pool::new(Opts::from_url(&get_url())?)?;

    let mut conn = pool.get_conn()?;

    let res: Vec<data_types::DataRow> = conn.query_fold(
        format!(
            "select
            month(month) as month,
            item_id,
            item_info,
            country,
            value
            {}
            from {}
            natural join products
            natural join product_groups
            natural join country_groups
            {}
            order by
            item_id, country;",
            &fulfillable, &table, &where_stmt
        ),
        Vec::new(),
        |mut acc: Vec<data_types::DataRow>, mut row: Row| {
            let item_id = row.take("item_id").unwrap();
            let country = row
                .take::<String, _>("country")
                .unwrap()
                .to_ascii_uppercase();

            let item_info = row.take("item_info").unwrap();
            let month = row.take::<usize, _>("month").unwrap() - 1;
            let value = row.take("value").unwrap();

            match acc.last_mut() {
                Some(el) if el.item_id == item_id && el.country == country => {
                    el.values[month] += value;
                    el.sum += value;
                    el.fulfillable = match row.take::<i32, _>("fulfillable") {
                        Some(val) if val == 0 && month < el.fulfillable => month,
                        _ => el.fulfillable,
                    }
                }
                _ => {
                    let mut el = data_types::DataRow {
                        item_id,
                        item_info,
                        country,
                        values: [0; 12],
                        sum: value,
                        fulfillable: match row.take::<i32, _>("fulfillable") {
                            Some(val) if val == 0 => month,
                            _ => 12,
                        },
                    };
                    el.values[month] = value;
                    acc.push(el);
                }
            }

            acc
        },
    )?;
    Ok(res)
}
