use serde::Serialize;
use std::collections::HashMap;

#[derive(Serialize)]
pub struct DataRow {
    pub country: String,
    pub item_id: String,
    pub item_info: String,
    pub sum: i32,
    pub values: [i32; 12],
    pub fulfillable: usize,
}

#[derive(Serialize)]
pub struct DataSum {
    pub values: Vec<i32>,
}

// Name of column and distinct values in that column
#[derive(Serialize)]
pub struct Column {
    pub name: String,
    pub values: Vec<String>,
}

#[derive(FromForm)]
pub struct UpdatedColumn<'r> {
    pub demand_id: &'r str,
    pub item_id: &'r str,
    pub country: &'r str,
    pub month: i32,
    pub value: i32,
}

#[derive(FromForm)]
pub struct RequestTable<'r> {
    pub table: &'r str,
    pub where_requirements: HashMap<&'r str, &'r str>,
}
