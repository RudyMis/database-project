pub mod get;
pub mod update;

use rocket::fairing::{Fairing, Info, Kind};
use rocket::http::Header;
use rocket::response::content;
use rocket::serde::json::Json;
use rocket::{Request, Response};
use std::collections::HashMap;

#[macro_use]
extern crate rocket;

#[get("/values/<table>?<where_requirements>")]
fn distinct_values(
    table: &str,
    where_requirements: HashMap<&'_ str, &'_ str>,
) -> content::Json<String> {
    let values = get::get_distinct_values(table.to_string(), where_requirements);
    match values {
        Ok(map) => content::Json(serde_json::to_string(&map).unwrap()),
        Err(err) => content::Json(format!("Error in database {}", err)),
    }
}

#[get("/data?sum&<table>&<where_requirements>")]
fn sum_from_table(
    table: &'_ str,
    where_requirements: HashMap<&'_ str, &'_ str>,
) -> content::Json<String> {
    let res = get::get_sum(table, where_requirements);
    match res {
        Err(err) => content::Json(err.to_string()),
        Ok(val) => content::Json(serde_json::to_string(&val).unwrap()),
    }
}

#[get("/data?<table>&<where_requirements>")]
fn data_from_table(
    table: &'_ str,
    where_requirements: HashMap<&'_ str, &'_ str>,
) -> content::Json<String> {
    let data = get::get_data_cell(&table, where_requirements);
    match data {
        Err(err) => content::Json(err.to_string()),
        Ok(vec) => content::Json(serde_json::to_string(&vec).unwrap()),
    }
}

#[post("/update", format = "json", data = "<row>")]
fn update_value(row: Json<update::Row>) -> content::Json<String> {
    let val = update::update_row(row.into_inner());
    match val {
        Ok(val) => content::Json(serde_json::to_string(&val).unwrap()),
        Err(err) => content::Json(format!("Error in database {}", err)),
    }
}

#[options("/update")]
fn fairy() -> &'static str {
    "Ok"
}

// CORS problem
// https://stackoverflow.com/a/69342225
pub struct CORS;

#[rocket::async_trait]
impl Fairing for CORS {
    fn info(&self) -> Info {
        Info {
            name: "Add CORS headers to responses",
            kind: Kind::Response,
        }
    }
    async fn on_response<'r>(&self, _request: &'r Request<'_>, response: &mut Response<'r>) {
        response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
        response.set_header(Header::new(
            "Access-Control-Allow-Methods",
            "POST, GET, PATCH, OPTIONS",
        ));
        response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
        response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/v1", routes![distinct_values])
        .mount("/v1", routes![data_from_table])
        .mount("/v1", routes![sum_from_table])
        .mount("/v1", routes![update_value])
        .mount("/v1", routes![fairy])
        .attach(CORS)
}
