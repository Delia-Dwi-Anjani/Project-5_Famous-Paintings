-- DATA EXPORATION --
#Menampilkan semua data
SELECT *
FROM `project2-famous-painting.Famous_Painting.artist`;

-- DATA UNDERSTANDING --
#Total Data
SELECT COUNT(*) AS total_artist
FROM `project2-famous-painting.Famous_Painting.artist`;

#Struktur Kolom
SELECT column_name, data_type
FROM `project2-famous-painting.Famous_Painting.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'artist';

-- DATA QUALITY CHECK
#Missing Values
SELECT
  COUNTIF(artist_id IS NULL) AS artist_id,
  COUNTIF(full_name IS NULL) AS full_name
FROM `project2-famous-painting.Famous_Painting.artist`;

#Duplicate ID
SELECT artist_id, COUNT(*) AS total
FROM `project2-famous-painting.Famous_Painting.artist`
GROUP BY artist_id
HAVING COUNT(*) > 1;

-- DATA CLEANING
#Membersihkan spasi dan menangani nama yang kosong
SELECT
  artist_id,
  COALESCE(NULLIF(TRIM(full_name), ''), 'Unknown') AS full_name
FROM `project2-famous-painting.Famous_Painting.artist`;

-- DATA PREPARATION
#Menyiapkan data dengan CTE
WITH artist_clean AS (
  SELECT
    artist_id,
    TRIM(full_name) AS artist_name
  FROM `project2-famous-painting.Famous_Painting.artist`
)
SELECT *
FROM artist_clean;

-- Exploratory Data Analysis (EDA)
#Hitung jumlah seniman berdasarkan kewarganegaraan
SELECT
  nationality,
  COUNT(*) AS total_artist
FROM `project2-famous-painting.Famous_Painting.artist`
GROUP BY nationality
ORDER BY total_artist DESC;

#Menampilkan 10 kewarganegaraan dengan jumlah seniman terbanyak
SELECT
nationality,
  COUNT(*) AS total_artist
FROM `project2-famous-painting.Famous_Painting.artist`
WHERE nationality IS NOT NULL
GROUP BY nationality
ORDER BY total_artist DESC
LIMIT 10;

-- FINAL DATASET
CREATE OR REPLACE VIEW
`project2-famous-painting.Famous_Painting.artist_summary` AS
SELECT
  nationality,
  COUNT(*) AS total_artist
FROM `project2-famous-painting.Famous_Painting.artist`
GROUP BY nationality;

-- VIEW DASHBOARD
CREATE OR REPLACE VIEW
  `project2-famous-painting.Famous_Painting.famous_paintings_dashboard`
AS

SELECT
  w.work_id,
  w.name AS painting_name,
  w.style AS art_style,
  w.artist_id,
  a.full_name AS artist_name,
  a.nationality,
  w.museum_id,
  m.name AS museum_name,
  m.country,
  m.city

FROM `project2-famous-painting.Famous_Painting.work` AS w

LEFT JOIN `project2-famous-painting.Famous_Painting.artist` AS a
  ON w.artist_id = a.artist_id

LEFT JOIN `project2-famous-painting.Famous_Painting.museum` AS m
  ON w.museum_id = m.museum_id;

#Memeriksa hasil
SELECT *
FROM `project2-famous-painting.Famous_Painting.famous_paintings_dashboard`
LIMIT 10;

-- TAMBAHAN KOLOM
#Membuat VIEW Canvas Size
CREATE OR REPLACE VIEW
`project2-famous-painting.Famous_Painting.canvas_size_summary`
AS

SELECT
  CAST(ps.work_id AS STRING) AS work_id,
  STRING_AGG(
    DISTINCT CONCAT(
      CAST(cs.width AS STRING),
      ' x ',
      CAST(cs.height AS STRING)
    ),
    ', '
  ) AS canvas_size

FROM `project2-famous-painting.Famous_Painting.product_size` ps

LEFT JOIN `project2-famous-painting.Famous_Painting.canvas_size` cs
  ON CAST(ps.size_id AS STRING) =
     CAST(cs.size_id AS STRING)

GROUP BY work_id;

#Menggabungkan dengan Dashboard
CREATE OR REPLACE VIEW
`project2-famous-painting.Famous_Painting.famous_paintings_dashboard_v2`
AS

SELECT
  d.*,
  c.canvas_size

FROM `project2-famous-painting.Famous_Painting.famous_paintings_dashboard` d

LEFT JOIN `project2-famous-painting.Famous_Painting.canvas_size_summary` c
  ON CAST(d.work_id AS STRING) = c.work_id;

