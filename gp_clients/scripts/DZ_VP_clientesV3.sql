DECLARE @Company VARCHAR(10) = 'Diez',
		--@Inicio DATE = '2023-01-31',@Fin DATE = '2023-02-28'
		@Period DATE = EOMONTH(DATEADD(MONTH , -1, eomonth(cast(getdate() as date))))
--INSERT INTO CorporateDESA.dbo.GP_clients (Period, Company, Country, Client_ID, CIF, Razón_social, Fecha_alta, Antig_meses,
--		GEOCountry, GEOCountryEng, GEOCountryESP, GEOCCAA, GEOCCAAName, GEOProvince,GEOProvinceName, Postal_code)	
SELECT 	Period, Company, Country, Client_ID, CIF, Razón_social, Fecha_alta, Antig_meses,
		GEOCountry, GEOCountryEng, GEOCountryESP, GEOCCAA, GEOCCAAName, GEOProvince,GEOProvinceName, Postal_code
		--CLI_dir,CLI_pos, CLI_pob, SUM(ARR)		
FROM (
	SELECT
		Period_End as Period,
		Company ,
		Country ,
		Client_ID ,
		ISNULL(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(NIF),'-',''),' ',''),'/',''),'.',''),'ES','')), CONCAT('Client_ID',Client_ID)) as CIF,
		ISNULL(UPPER(trim(NOM)),CONCAT('Client_ID', Client_ID)) as Razón_social,
		CASE WHEN FECALT > 18991231 THEN convert(date, CAST(FECALT AS varchar(10)))  END AS Fecha_alta, --FECALT menos que esto son user de prueba y da error el cast
		CASE WHEN FECALT > 18991231 THEN DATEDIFF(MONTH, convert(date, CAST(FECALT AS varchar(10))), Period_End) END AS Antig_meses,
		geo.Country_code AS GEOCountry,
		geo.CountryNameENG AS GEOCountryEng,
		geo.CountryNameESP AS GEOCountryESP,
		geo.GEOCCAA AS GEOCCAA, --codigo CCAA
		geo.GEOCCAAName AS GEOCCAAName,
		geo.GEOProvince AS GEOProvince,
		geo.GEOProvinceName as GEOProvinceName,
		geo.Postal_code AS Postal_code,
		/*CHECK*/
		--Cli.POS as CLI_pos,
		--Cli.DIR as CLI_dir,
		--Cli.PRO as CLI_pro,
		--Cli.POB as CLI_pob,--ESTO tb me lo traigo de DIR para poder rellenar mas vacíos
		--ARR,
		ROW_NUMBER() OVER (PARTITION BY Client_ID,Period_End ORDER BY Period_End) as orden --Same client_ID have several products, just shows oldest product.
	
	FROM CorporateDESA.dbo.WIP_full_output_table dzout
	LEFT JOIN (
			SELECT ID, NIF, NOM, USU, FECALT, POS, POB, CAST(PRO as VARCHAR(5)) as PRO, DIR FROM CorporateKPIs_DATA.dbo.dz_ClientesDiez WHERE NOM NOT LIKE '%prueba%'
			UNION ALL 
			SELECT ID, NIF, NOM, USU, FECALT, POS, POB, CAST(PROV as VARCHAR(5)) as PRO, DIR FROM CorporateKPIs_DATA.dbo.dz_CLIENTESNUEVOSDM
			) Cli
		ON dzout.Client_ID = Cli.ID
	LEFT JOIN CorporateDESA.dbo.VP_DIM_Geographic geo
		ON ((geo.Postal_code = TRIM(Cli.POS) AND geo.GEOProvince = CAST(PRO as VARCHAR(8)) )
		OR (CASE 
			WHEN TRIM(Cli.POS) = '1836' THEN '18360'
			WHEN TRIM(Cli.POS) = '49902' AND TRIM(Cli.POB) = 'Barakaldo' THEN '48902'
			WHEN TRIM(Cli.POS) = '2052' AND TRIM(Cli.POB) = 'ALMERIA' THEN '04052'
			WHEN TRIM(Cli.POS) = '69600' AND TRIM(Cli.POB) = 'CAMARGO' THEN '39609'
			WHEN TRIM(Cli.POS) = 'Mósto' THEN '28931'
			WHEN TRIM(Cli.POB) = 'PALLEJÀ' THEN '08780'
			WHEN TRIM(Cli.POS) = '1539' AND TRIM(Cli.POB) = 'ALICANTE' THEN '03001'
			WHEN TRIM(Cli.POB) = 'Arconada' AND TRIM(Cli.POS) = '37449' THEN '34449'
			WHEN TRIM(Cli.POS) = 'GIJON' THEN '33201'
			WHEN TRIM(Cli.POB) = 'GRANADA' THEN '18817'
			WHEN TRIM(Cli.POB) = 'Sabadell' THEN '08192'
			WHEN TRIM(Cli.POB) = 'PALMA' THEN '07001'
			WHEN TRIM(Cli.POS) IS NULL AND TRIM(Cli.POB) IS NULL THEN 'ESPAÑA'
			ELSE TRIM(Cli.POS) END = geo.Postal_code)
		
		OR (CASE /*Arreglamos todos los CP que tienen LEN 4 y cuya provincia tiene un solo dígito EJ: Provincia 8 y CP 8100 --> Provincia 08 y CP 08100*/ 
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '8') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '7') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '1') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '2') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '3') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '4') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '6') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '9') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '5') THEN CONCAT('0', TRIM(Cli.POS))
			WHEN (LEN(TRIM(Cli.POS)) = 4 AND CAST(PRO as VARCHAR(8)) = '18') THEN CONCAT(TRIM(Cli.POS),'0')
			WHEN ((CLi.PRO)= '21' AND TRIM(Cli.POS) = '24440') THEN '21440'
			WHEN ((CLi.PRO)= '38' AND TRIM(Cli.POS) = 'La cu') THEN '38110'
			ELSE TRIM(Cli.POS) END = geo.Postal_code )	
		OR (CASE /*Para los códigos postales que tienen solo 4 dígitos*/ 
			WHEN LEN(Cli.POS) = 4 THEN CONCAT('0',TRIM(Cli.POS))
			WHEN (Cli.POS IS NULL AND Cli.DIR IS NULL AND Cli.POB IS NULL) THEN '00000'--Si no hay datos registrados se asignan a Provincia = ESPAÑA
			WHEN Cli.POS = 'Palos' THEN '21810'
			ELSE (Cli.POS)END = geo.Postal_code ) )
	WHERE period_end = @Period
	AND Company = @Company
	) q_client
WHERE orden = 1;
--AND GEOCountry IS NULL
--GROUP BY CLI_dir,CLI_pos, CLI_pob
--ORDER BY SUM(ARR)DESC
--AND Client_ID = '100372';
/*** Importes de ARR y cantidad de productos por Familia ***/
/*
UPDATE cli 
SET ARR=b.ARR, Change_ARR=b.Price_change, PF_SaaS=b.q_saas, PF_Cloud=b.q_cloud, PF_Maintenance=b.q_maint
	, PF_Subscription=b.q_subscript, PF_others=b.q_other, Up_change=b.up_change, Down_change=b.down_change, Cross_change=b.cross_change, Migration_change=b.mig_change
	, Transfer_change=b.transfer_change, Index_change=b.index_change
FROM CorporateDESA.dbo.GP_clients cli
JOIN (SELECT Company, Client_ID, Period_End
	, sum(CASE WHEN Product_Family='Maintenance' THEN 1 ELSE 0 END) AS q_maint
	, sum(CASE WHEN Product_Family='Cloud Services' THEN 1 ELSE 0 END) AS q_cloud
	, sum(CASE WHEN Product_Family='SaaS' THEN 1 ELSE 0 END) AS q_saas
	, sum(CASE WHEN Product_Family='Subscription' THEN 1 ELSE 0 END) AS q_subscript
	, sum(CASE WHEN Product_Family='Other' THEN 1 ELSE 0 END) AS q_other
	, sum(ARR) AS ARR, sum(Price_Change) AS Price_change
	, sum(CASE WHEN Bridge_Category='Upsell' THEN Price_Change ELSE 0 END) AS up_change
	, sum(CASE WHEN Bridge_Category='Downsell' THEN Price_Change ELSE 0 END) AS down_change
	, sum(CASE WHEN Bridge_Category='Cross_Sell' THEN Price_Change ELSE 0 END) AS cross_change
	, sum(CASE WHEN Bridge_Category='Migration' THEN Price_Change ELSE 0 END) AS mig_change
	, sum(CASE WHEN Bridge_Category='Transfer' THEN Price_Change ELSE 0 END) AS transfer_change
	, sum(CASE WHEN Bridge_Category='Indexation' THEN Price_Change ELSE 0 END) AS index_change

	FROM CorporateDESA.dbo.WIP_dz_output_table
	GROUP BY Company, Client_ID, Period_End
	)b ON cli.Company = b.Company AND cli.Client_ID = b.Client_ID AND cli.Period = b.Period_End
WHERE cli.Company = @Company
AND period_end = @Period;
/*** Cantidad Total de productos ***/
UPDATE cli 
SET q_prod=b.q_prod
FROM CorporateDESA.dbo.GP_clients cli
JOIN (SELECT Company, Client_ID, Period_End, count(DISTINCT isnull(Product_ID,'')) AS q_prod
	FROM CorporateDESA.dbo.WIP_dz_output_table
	WHERE period_end = @Period
	GROUP BY Company, Client_ID, Period_End
	)b ON cli.Company = b.Company AND cli.Client_ID = b.Client_ID AND cli.Period = b.Period_End 
WHERE cli.Company = @Company
;
/*** Último movimiento 
UPDATE cli
SET last_mov=b.Bridge_Category
FROM CorporateDESA.dbo.GP_clients cli
JOIN (SELECT a.Company, a.Client_ID, a.Period_End, a.Bridge_Category
	FROM CorporateDESA.dbo.WIP_dz_output_table a
	JOIN (
	SELECT Company, Client_ID, Period_End, count(*) AS q 
	FROM 
		(SELECT Company, Client_ID, Period_End, Bridge_Category FROM CorporateDESA.dbo.WIP_dz_output_table
		WHERE period_end = @Period
		GROUP BY Company, Client_ID, Period_End, Bridge_Category) c
	GROUP BY Company, Client_ID, Period_End
	HAVING count(*)=1
		)sub ON a.Company = sub.Company AND a.Client_ID = sub.Client_ID AND a.Period_End = sub.Period_End
	)b ON cli.Company = b.Company AND cli.Client_ID = b.Client_ID AND cli.Period = b.Period_End 
WHERE cli.Company = @Company
;
UPDATE cli
SET last_mov=b.ult_mov
FROM CorporateDESA.dbo.GP_clients cli
JOIN (	
	SELECT Company, Client_ID, Period_End, CAST((
        SELECT  T.Bridge_Category+','
        FROM (
        	SELECT Company, Client_ID, Period_End, Bridge_Category FROM CorporateDESA.dbo.WIP_dz_output_table
			GROUP BY Company, Client_ID, Period_End, Bridge_Category
			) T
        WHERE A.Company=T.Company AND A.Client_ID=T.Client_ID AND A.Period_End = T.Period_End
        FOR XML PATH(''))as varchar(max)
        ) as ult_mov 
	FROM CorporateDESA.dbo.WIP_dz_output_table a
	WHERE period_end = @Period
	--= @Period
	GROUP BY Company, Client_ID, Period_End
	)b ON cli.Company = b.Company AND cli.Client_ID = b.Client_ID AND cli.Period = b.Period_End
WHERE last_mov IS NULL 
AND cli.Company = @Company
;*/