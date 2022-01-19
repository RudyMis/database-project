use mysql::prelude::*;
use mysql::*;
use rocket::serde::Deserialize;
use std::env;
use urlencoding::decode;

#[derive(Deserialize)]
pub struct Row<'r> {
    pub demand_id: &'r str,
    pub item_id: &'r str,
    pub country: &'r str,
    pub month: &'r str,
    pub value: i32,
}

fn get_url() -> String {
    format!(
        "mysql://rust:rust-password@{}:3306/database",
        &env::var("DATABASE_HOSTNAME").unwrap()
    )
}

pub fn update_row(row: Row) -> Result<Vec<String>> {
    let pool = Pool::new(Opts::from_url(&get_url())?)?;

    let mut conn = pool.get_conn()?;

    let query = format!(
        "update demand set value = {}
        where
        demand_id='{}' and
        item_id='{}' and
        country='{}' and
        left(lower(monthname(month)), 3)='{}'",
        &row.value,
        &decode(row.demand_id).unwrap(),
        &decode(row.item_id).unwrap(),
        &decode(row.country).unwrap(),
        &row.month
    );

    let res: Vec<String> = conn.query(query)?;

    Ok(res)
}
