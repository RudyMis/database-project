use database;

-- Load main file
create or replace table product_data (
    FINCL_YR CHAR(10) not null,
    ITEM_CD CHAR(16) not null,
    ITEM_DESCR CHAR(100) not null,
    PLNT_DESCR CHAR(100) not null,
    JAN int not null,
    FEB int not null,
    MAR int not null,
    APR int not null,
    MAY int not null,
    JUN int not null,
    JUL int not null,
    AUG int not null,
    SEP int not null,
    OCT int not null,
    NOV int not null,
    `DEC` int not null,
    FY int not null,
    XLVL7_DESCR CHAR(100) not null,
    XLVL6_DESCR CHAR(100) not null,
    XLVL4_DESCR CHAR(100) not null,
    CNTRY_LVL5_DESCR CHAR(100) not null,
    CNTRY_LVL4_DESCR CHAR(100) not null,
    CNTRY_LVL2_DESCR CHAR(32) not null
);

load data infile '/data/database.csv'
into table product_data
fields terminated by ';'
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

commit;

-- Better product_data
create or replace table product_data_v2 (
    fincl_yr CHAR(10) not null,
    item_cd CHAR(16) not null,
    plnt_descr CHAR(100) not null,
    month int not null,
    `value` int not null,
    country CHAR(32) not null
);

-- Fufufu
-- Switch from 12 columns with values to one with date and one with value
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 1 as month, JAN as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 2 as month, FEB as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 3 as month, MAR as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 4 as month, APR as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 5 as month, MAY as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 6 as month, JUN as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 7 as month, JUL as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 8 as month, AUG as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 9 as month, SEP as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 10 as month, OCT as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 11 as month, NOV as `value`, CNTRY_LVL2_DESCR from product_data;
insert into product_data_v2 select FINCL_YR, ITEM_CD, PLNT_DESCR, 12 as month, `DEC` as `value`, CNTRY_LVL2_DESCR from product_data;

commit;

-- Create smaller tables

drop table if exists demand;
drop table if exists production;
drop table if exists budget;
drop table if exists country_groups;
drop table if exists products;
drop table if exists product_groups;

create or replace table product_groups (
    item_id CHAR(16) not null primary key,
    xlvl4_descr CHAR(100) not null,
    xlvl6_descr CHAR(100) not null,
    xlvl7_descr CHAR(100) not null
);

create or replace table products (
    item_id CHAR(16) not null primary key,
    item_info CHAR(100) not null,
    constraint product_group foreign key (item_id)
        references product_groups (item_id)
);

create or replace table country_groups (
    country CHAR(32) not null primary key,  -- Kraje
    local_region CHAR(100) not null,         -- Małe regiony
    region CHAR(100) not null                -- Regiony
);

-- Planned expenses on yearly basis
create or replace table budget (
    month DATE not null,
    item_id CHAR(16) not null,
    plnt_descr CHAR(100) not null,
    country CHAR(32) not null,
    `value` int not null,
    primary key (month, item_id, country),

    constraint budget_item_info foreign key (item_id)
        references products (item_id),
    constraint budget_item_group foreign key (item_id)
        references product_groups (item_id),

    constraint budget_country_group foreign key (country)
        references country_groups (country)
);

-- Max production
create or replace table production (
    month DATE not null,
    item_id CHAR(16) not null,
    plnt_descr CHAR(100) not null,
    country CHAR(32) not null,
    `value` int not null,
    primary key (month, item_id, country),

    constraint prod_item_info foreign key (item_id)
        references products (item_id),
    constraint prod_item_group foreign key (item_id)
        references product_groups (item_id),

    constraint prod_country_group foreign key (country)
        references country_groups (country)
);

-- Planned expenses on montly basis
create or replace table demand (
    demand_id CHAR(5) not null,
    month DATE not null,
    item_id CHAR(16) not null,
    country CHAR(32) not null,
    `value` int not null,
    fulfillable boolean,
    primary key (demand_id, month, item_id, country),

    constraint budget foreign key (month, item_id, country)
        references budget (month, item_id, country),
    constraint prod foreign key (month, item_id, country)
        references production (month, item_id, country),

    constraint dmd_item_info foreign key (item_id)
        references products (item_id),
    constraint dmd_item_group foreign key (item_id)
        references product_groups (item_id),

    constraint dmd_country_group foreign key (country)
        references country_groups (country)
);

commit;

-- Trigger checks whether demand exceeds production
-- (It is placed after cuting tables because it was very slow otherwise)
delimiter //
create or replace trigger max_production_check
before update on demand
for each row
begin
    set @sum_diff = 0;
    -- Przez rozdzielenie selecta chyba ten pierwszy jet cache'owany
    with joined as (
        select
            dmd.demand_id, dmd.month, dmd.item_id, dmd.country, pro.`value` - dmd.`value` as val
        from demand dmd left join production pro on
            dmd.item_id = pro.item_id and
            dmd.month = pro.month and
            dmd.country = pro.country
    )
    select sum(val)
    into @sum_diff
    from joined
    where
        joined.demand_id = new.demand_id and
        joined.item_id = new.item_id and
        joined.country = new.country and
        month(joined.month) <= month(new.month) and
        year(joined.month) = year(new.month);

    if @sum_diff - new.`value` + old.`value` < 0 then
        set new.fulfillable=false;
    else
        set new.fulfillable=true;
    end if;
end; //
delimiter ;

-- Copy of above, but on insert (mariadb doesn't accept (insert or update))
delimiter //
create or replace trigger max_production_check
before insert on demand
for each row
begin
    set @sum_diff = 0;
    -- Przez rozdzielenie selecta chyba ten pierwszy jet cache'owany
    with joined as (
        select
            dmd.demand_id, dmd.month, dmd.item_id, dmd.country, pro.`value` - dmd.`value` as val
        from demand dmd left join production pro on
            dmd.item_id = pro.item_id and
            dmd.month = pro.month and
            dmd.country = pro.country
    )
    select sum(val)
    into @sum_diff
    from joined
    where
        joined.demand_id = new.demand_id and
        joined.item_id = new.item_id and
        joined.country = new.country and
        month(joined.month) <= month(new.month) and
        year(joined.month) = year(new.month);

    if @sum_diff - new.`value` < 0 then
        set new.fulfillable=false;
    else
        set new.fulfillable=true;
    end if;
end; //
delimiter ;

commit;

-- Insert data onto new tables

insert into product_groups
select
    item_cd as item_id,
    xlvl4_descr,
    xlvl6_descr,
    xlvl7_descr
from product_data
group by item_id;

insert into products 
select
    item_cd as item_id,
    item_descr as item_info 
from product_data
group by 
    item_id;

insert into country_groups
select
    cntry_lvl2_descr as country,
    cntry_lvl4_descr as local_region,
    cntry_lvl5_descr as region
from product_data
group by cntry_lvl2_descr;

insert into production
select * from (select
    str_to_date(
        concat(
            '2021 ',
            month,
            ' 1'
        ),
        '%Y %c %e'),
    item_cd,
    plnt_descr,
    country,
    `value` as val
from product_data_v2 
where fincl_yr='PRODUCTION') as t
on duplicate key update `value` = `value` + t.val;

-- I don't have data for next year's production
-- So I just copy other year
insert into production
select * from (select
    str_to_date(
        concat(
            '2022 ',
            month,
            ' 1'
        ),
        '%Y %c %e'),
    item_cd,
    plnt_descr,
    country,
    `value` as val
from product_data_v2 
where fincl_yr='PRODUCTION') as t
on duplicate key update `value` = `value` + t.val;

insert into budget
select * from (select
    str_to_date(
        concat(
            '20',
            right(fincl_yr, 2),
            ' ',
            month,
            ' 1'
        ),
        '%Y %c %e'),
    item_cd,
    plnt_descr,
    country,
    `value` as val
from product_data_v2
where fincl_yr like 'BUDGET%') as t
on duplicate key update `value` = `value` + t.val;

-- This generates lots of warnings
-- because there are items that aren't in budget so i just ignore them
insert ignore into demand (demand_id, month, item_id, country, `value`, fulfillable)
select * from (select
    right(fincl_yr, 5),
    str_to_date(
        concat(
            '20',
            left(right(fincl_yr, 5), 2),
            ' ',
            month,
            ' 1'
        ),
        '%Y %c %e'),
    item_cd,
    country,
    `value` as val,
    true
from product_data_v2
where fincl_yr like 'DMD%') as t
on duplicate key update `value` = `value` + t.val;

commit;

/* select sum(`value`) */
/* from production */
/* where month(month) <= 1 and */
/* year(month) = 2022 and */
/* item_id = '1503353' and */
/* country = 'SOUTH AFRICA' */
/* group by item_id, country; */

/* select * */
/* from demand */
/* where */ 
/* demand_id = '22 05' and */
/* month(month) <= 1 and */
/* year(month) = 2022 and */
/* item_id = '1503353' and */
/* country = 'SOUTH AFRICA'; */

-- update demand set demand.`value` = demand.`value` + 5000 where demand_id='22 11' and country = 'POLAND' and item_id = 'Z1MC3490' and month = '2022-05-01';

/* with joined as ( */
/*     select */
/*         dmd.demand_id, dmd.month, dmd.item_id, dmd.country, pro.`value` - dmd.`value` as val */
/*     from demand dmd left join production pro on */
/*         dmd.item_id = pro.item_id and */
/*         dmd.month = pro.month and */
/*         dmd.country = pro.country */
/* ) */
/* select sum(val) */
/* /1* into @res *1/ */
/* from joined */
/* where */
/*     joined.demand_id = '22 11' and */
/*     joined.item_id = 'Z1MC3490' and */
/*     joined.country = 'POLAND' and */
/*     month(joined.month) <= 5 and */
/*     year(joined.month) = 2022; */


-- select demand.month, demand.`value` as demand, production.`value` as prod
-- from demand left join production on
--     demand.month = production.month and
--     demand.country = production.country and
--     demand.item_id = production.item_id
-- where demand_id='22 11' and demand.country = 'POLAND' and demand.item_id = 'Z1MC3490';

-- select * from demand where demand_id='22 11' and country = 'POLAND' and item_id = 'Z1MC3490';

-- select demand_id, sum(`value`)
-- -- into @sum_demand
-- from demand
-- where
--     -- demand.demand_id = '22 11' and
--     month(month) < 12 and
--     year(month) = 2022 and
--     item_id = 'Z1MC3490' and
--     country = 'POLAND'
-- group by demand_id, item_id, country;

-- select item_id, country, sum(`value`)
-- -- into @sum_demand
-- from production
-- where
--     -- demand.demand_id = '22 11' and
--     month(month) <= 12 and
--     year(month) = 2022 and
--     item_id = 'Z1MC3490' and
--     country = 'POLAND'
-- group by item_id, country;

-- select item_id, country, sum(`value`) from demand group by demand_id, item_id, country;
-- select item_id, country, sum(`value`) from production group by item_id, country;

