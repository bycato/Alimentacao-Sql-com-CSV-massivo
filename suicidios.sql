create database datasus;
use datasus;

create table suicidios(
	id int not null auto_increment primary key,
    ano int(4),
    idade int(3),
    sexo enum("Masculino", "Feminino"),
    id_estado int,
    id_estado_civil int,
	id_escolaridade int,
    id_causa int,
    
    foreign key (id_estado) references estados(id),
    foreign key (id_estado_civil) references estado_civil(id),
    foreign key (id_escolaridade) references escolaridade(id),
    foreign key (id_causa) references causas(id)
);

create table estados(
	id int not null auto_increment primary key,
    sigla varchar(5) unique
);


create table estado_civil(
	id int not null auto_increment primary key,
    estciv varchar(50) unique
);


create table escolaridade(
	id int not null auto_increment primary key,
    esc varchar(50) unique
);


create table causas(
	id int not null auto_increment primary key,
    causabas varchar(5) unique, 
    causabas_o varchar(5) unique
);


SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/AntonioNeto/Downloads/suicidios_2010_a_2019.csv/file0.csv'
into table suicidios fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 lines (ano, idade, sexo);

LOAD DATA LOCAL INFILE 'C:/Users/AntonioNeto/Downloads/suicidios_2010_a_2019.csv/file0.csv'
into table estados fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 lines (@dummy, sigla); -- @dummy é um ignorador.

LOAD DATA LOCAL INFILE 'C:/Users/AntonioNeto/Downloads/suicidios_2010_a_2019.csv/file0.csv'
into table estado_civil fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 lines (@dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, estciv);  

-- 5: dataobt, 6: datanasc , 7: sexo
TRUNCATE TABLE estado_civil;

LOAD DATA LOCAL INFILE 'C:/Users/AntonioNeto/Downloads/suicidios_2010_a_2019.csv/file0.csv'
into table escolaridade fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 lines (@dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, esc);  

LOAD DATA LOCAL INFILE 'C:/Users/AntonioNeto/Downloads/suicidios_2010_a_2019.csv/file0.csv'
into table causas fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' ignore 1 lines (@dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, causabas, causabas_o);  


SELECT * FROM estados;
SELECT * FROM estado_civil;
SELECT * FROM escolaridade;
SELECT * FROM causas;

CREATE TEMPORARY TABLE temp_suicidios_bruto (
	id int,
    txt_sigla VARCHAR(5),
    ano int(4),
    data_obt date,
    data_nasc date,
    sexo VARCHAR(20),
    txt_estciv VARCHAR(50),
    txt_esc VARCHAR(50),
    txt_causabas VARCHAR(5),
    txt_causabas_o VARCHAR(5)
);

drop temporary table temp_suicidios_bruto;

LOAD DATA LOCAL INFILE 'C:/Users/AntonioNeto/Downloads/suicidios_2010_a_2019.csv/file0.csv'
INTO TABLE temp_suicidios_bruto
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, txt_sigla, ano, @dummy, data_obt, data_nasc, sexo, @dummy, @dummy, @dummy, txt_estciv, txt_esc, @dummy, @dummy, txt_causabas, txt_causabas_o);

select * from temp_suicidios_bruto;
TRUNCATE TABLE temp_suicidios_bruto;

INSERT INTO suicidios (ano, idade, sexo, id_estado, id_estado_civil, id_escolaridade, id_causa)
SELECT 
    t.ano,
    -- CALCULA A IDADE EM ANOS AQUI:
    TIMESTAMPDIFF(YEAR, t.data_nasc, t.data_obt) AS idade, 
    IF(t.sexo LIKE '%Masc%', 'Masculino', 'Feminino'), 
    e.id,  
    ec.id, 
    esc.id,
    c.id   
FROM temp_suicidios_bruto t
LEFT JOIN estados e ON e.sigla = t.txt_sigla
LEFT JOIN estado_civil ec ON ec.estciv = t.txt_estciv
LEFT JOIN escolaridade esc ON esc.esc = t.txt_esc
LEFT JOIN causas c ON c.causabas = t.txt_causabas AND c.causabas_o = t.txt_causabas_o;

SELECT * FROM suicidios;


-- selects & views
-- 1
create view idade_sexo_estado as select s.idade, s.sexo, e.sigla from suicidios s join estados e on s.id_estado = e.id; 
select * from idade_sexo_estado;

-- 2
create view total_obt_estado as select e.sigla, count(e.sigla) from suicidios s join estados e on s.id_estado = e.id group by e.sigla;
select * from total_obt_estado;

-- 3
create view top10_estados as select e.sigla, count(e.sigla) as quantidade from suicidios s join estados e on s.id_estado = e.id group by e.sigla order by quantidade desc;
select * from top10_estados;

-- 4
create view grupos_escolaridade as select e.esc, count(s.id_escolaridade) as quantidade from suicidios s join escolaridade e on s.id_escolaridade = e.id group by e.esc;  
select * from grupos_escolaridade;

-- 5
create view grupos_estado_civil as select e.estciv, count(s.id_estado_civil) as quantidade from suicidios s join estado_civil e on s.id_estado_civil = e.id group by e.estciv;
select * from grupos_estado_civil;

-- 6
create view grupos_idade as select avg(s.idade) as media_idade, e.sigla from suicidios s join estados e on s.id_estado = e.id group by e.sigla;
select * from grupos_idade;

-- 7
create view relatorio_estados as select est.sigla, estciv.estciv, esc.esc, c.causabas, count(s.id) as quantidade from suicidios s
join estados est on s.id_estado = est.id
join estado_civil estciv on s.id_estado_civil = estciv.id
join escolaridade esc on s.id_escolaridade = esc.id
join causas c on s.id_causa = c.id
group by c.causabas;
select * from relatorio_estados;
