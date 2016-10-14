
---------ÕÒµ½rawdata---------
create table jh_hyod_rawdata as
select row_number() over (PARTITION BY veh_id ORDER BY "VEH_TIME" ASC),
"VEH_TIME",veh_id,veh_speed,veh_lon,veh_lat,veh_zaike,substr(mesh,7,4)||road_id roadid from beijing_all_hy_03
order by veh_id,"VEH_TIME";

----ÕÒµ½zaike diff
create table jh_hyod_cal_data0 as
select rank() over (partition by veh_id, veh_zaike order by row_number) R,*
from jh_hyod_rawdata
order by veh_id,"VEH_TIME";

create table jh_hyod_cal_data1 as
select row_number-R as gap,* from jh_hyod_cal_data0
order by veh_id,row_number;

create table jh_hyod_cal_data2 as
select 
row_number() over (PARTITION BY veh_id, gap ORDER BY "VEH_TIME" ASC) as new_row1,
row_number() over (PARTITION BY veh_id, gap ORDER BY "VEH_TIME" DESC) as new_row2,*
from jh_hyod_cal_data1
where veh_zaike =1
order by veh_id,"VEH_TIME";

create table jh_hyod_cal_data3 as
select veh_id,gap from jh_hyod_cal_data2
where new_row1=1 and new_row2>5;

create table jh_hyod_cal_data4 as
select jh_hyod_cal_data2.* from jh_hyod_cal_data2,jh_hyod_cal_data3
where jh_hyod_cal_data2.veh_id= jh_hyod_cal_data3.veh_id
and jh_hyod_cal_data2.gap= jh_hyod_cal_data3.gap;

create table beijing_od_hy_jh as
select "VEH_TIME",trim(veh_id),veh_speed,veh_lon,veh_lat,roadid,gap from jh_hyod_cal_data4_test
order by veh_id,"VEH_TIME";

copy (select * from beijing_od_hy_jh order by btrim,"VEH_TIME") to '/home/gpadmin/data/beijing_od_hy_jh.txt';


create table hy_o as
select veh_time,veh_id,gap,veh_speed,veh_lon,veh_lat,roadid from jh_hyod_cal_data4
where new_row1=1;
create table hy_d as
select veh_time,veh_id,gap,veh_speed,veh_lon,veh_lat,roadid from jh_hyod_cal_data4
where new_row2=1;