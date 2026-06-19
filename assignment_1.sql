create SCHEMA processes;

create table processes.accounts
(
    AccountID     int PRIMARY KEY,
    FULL_NAME     varchar(255) NOT NULL,
    Country       varchar(255),
    Status        varchar(255) NOT NULL,
    Email         varchar(255),
    Date_of_Birth date,
    Created_At    date
);

create table processes.server
(
    ServerIP        int PRIMARY KEY,
    Server_Name     varchar(255) NOT NULL,
    Location        varchar(255) NOT NULL,
    Max_Server_Load int
);

create table processes.player
(
    PlayerID   int PRIMARY KEY,
    NickName   varchar(255) NOT NULL,
    Level      int,
    ClassID    varchar(255) NOT NULL,
    AccountID  int          Not NULL,
    Activity   varchar(255),-- online/offline
    ServerIP   int,
    Started_At date
);

create table processes.classes
(
    ClassID    varchar(255) PRIMARY KEY,
    Class_Name varchar(255) NOT NULL,
    Start_Item varchar(255),
    HP         int          Not NULL,
    Mana       int
);

create table processes.logs
(
    LogId         int PRIMARY KEY,
    ServerIP      int,
    PlayerID      int,
    Start_Session date,
    End_Session   date,
    Info          varchar(255)
);
with full_player_info as (select player.playerid,
                                 player.nickname,
                                 player.level,
                                 player.accountid,
                                 classes.class_name,
                                 classes.hp,
                                 classes.mana,
                                 classes.start_item,
                                 accounts.country,
                                 accounts.status,
                                 accounts.full_name,
                                 accounts.email,
                                 server.server_name,
                                 server.location as server_location,
                                 logs.start_session,
                                 logs.end_session,
                                 logs.info
                          from processes.player
                                   Join processes.classes
                                        ON player.classid = classes.classid
                                   Join processes.accounts
                                        ON player.accountid = accounts.accountid
                                   Join processes.server
                                        ON player.serverip = server.serverip
                                   Left Join processes.logs
                                             ON player.playerid = logs.playerid),
     total_player_hours as (select country,
                                   class_name,
                                   playerid,
                                   nickname,
                                   sum(end_session - start_session) as total_hours
                            from full_player_info
                            where level >= 10
                            GROUP BY class_name, country, nickname, playerid),
     top_country_player as (select *,
                        row_number() over (partition by country ORDER BY total_hours desc) as place
       from total_player_hours
        where total_hours >= 5)
select * from top_country_player
where place <= 3;
