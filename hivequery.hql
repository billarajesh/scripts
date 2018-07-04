DROP DATABASE IF EXISTS smoketests CASCADE;
CREATE DATABASE IF NOT EXISTS smoketests;
CREATE EXTERNAL TABLE IF NOT EXISTS smoketests.books_ext (
  id VARCHAR(255),
  cat VARCHAR(255),
  name VARCHAR(255),
  price FLOAT,
  inStock BOOLEAN,
  author VARCHAR(255),
  series_t STRING,
  sequence_i INT,
  genre_s VARCHAR(255)
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/benchmarks/smoketests/hivesmoketest/';

CREATE TABLE IF NOT EXISTS smoketests.books_int (
  id VARCHAR(255),
  cat VARCHAR(255),
  name VARCHAR(255),
  price FLOAT,
  inStock BOOLEAN,
  author VARCHAR(255),
  series_t STRING,
  sequence_i INT,
  genre_s VARCHAR(255)
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
LOAD DATA LOCAL INPATH '/opt/cloudera/parcels/CDH/share/doc/solr*/example/exampledocs/books.csv' OVERWRITE INTO TABLE smoketests.books_int ;
