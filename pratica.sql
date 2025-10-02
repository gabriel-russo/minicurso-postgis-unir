CREATE SCHEMA pvh;

CREATE TABLE IF NOT EXISTS pvh.tb_bairros(
	id SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	nome VARCHAR(128) NOT NULL,
	descricao VARCHAR(1024),
	lei_de_criacao VARCHAR(64),
	lei_de_alteracao VARCHAR(64),
	zona_de_planejamento VARCHAR(64),
	geom GEOMETRY(Polygon, 31980) NOT NULL
);

CREATE TABLE IF NOT EXISTS pvh.tb_paradas_de_onibus(
    id SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    banco BOOLEAN,
    lixo BOOLEAN,
    coberto BOOLEAN,
    geom GEOMETRY(Point, 31980) NOT NULL
);

CREATE TABLE IF NOT EXISTS pvh.tb_itinerarios_de_onibus(
    id SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(48) NOT NULL,
    cod_integracao VARCHAR(8),
    ida GEOMETRY(Linestring, 31980) NOT NULL,
    volta GEOMETRY(Linestring, 31980)
);

-- Qual dos bairros possui a maior área em km²?
SELECT 
	nome AS bairro, 
	ST_Area(geom) / 1_000_000 AS area_km2 
FROM pvh.tb_bairros 
ORDER BY area_km2 DESC;

-- Qual dos bairros possui a maior quantidade pontos de ônibus?
SELECT 
	b.nome AS bairro, 
	COUNT(p.geom) AS qtd_paradas 
FROM pvh.tb_bairros AS b
JOIN pvh.tb_paradas_de_onibus AS p ON ST_Intersects(b.geom, p.geom)
GROUP BY b.nome 
ORDER BY qtd_paradas DESC;

-- Qual dos itinerários de ônibus possui a maior extensão (ida + volta)?
SELECT 
	cod_integracao || ' - '|| nome AS linha, 
	(ST_Length(ida) + COALESCE(ST_Length(volta), 0)) / 1_000 AS percurso 
FROM pvh.tb_itinerarios_de_onibus 
ORDER BY percurso DESC;

-- Qual dos itinerários passa por mais paradas na ida?
SELECT
	i.nome AS linha,
	COUNT(p.geom) AS paradas
FROM pvh.tb_itinerarios_de_onibus AS i
JOIN pvh.tb_paradas_de_onibus AS p ON ST_Crosses(i.ida, ST_Buffer(p.geom, 5))
GROUP BY i.nome
ORDER BY paradas DESC;
