/****** Object:  Procedure [dbo].[sp_3040_Processar]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_3040_Processar]
    @id_fundo       INT, 
    @data           DATE,
    @user           VARCHAR(50), 
    @cdError        INT OUTPUT, 
    @dsError        VARCHAR(500) OUTPUT,
    @parte          TINYINT = 1,
    @remessa        TINYINT = 1,
    @tipo_arquivo   CHAR(1) = 'F',
    @debug          INT = 0
AS
BEGIN

    DECLARE @cnpj_fundo VARCHAR(14),
	        @valor_agreg numeric(19,4)

    SELECT @cnpj_fundo = CD_CNPJ_FUNDO 
	FROM TB_3040_BAS_FUNDO 
	WHERE ID_FUNDO = @id_fundo

    SELECT @valor_agreg = CONVERT(NUMERIC, COALESCE(VALOR,0)) FROM TB_PARAMETRO WHERE NM_PARAMETRO = 'VALOR_AGREGACAO'
	
	---------INICIO:::: SETANDO VARIAVEIS CUTODIA 1 E 2
	DECLARE @ID_FUNDO_CUSTODIA INT,
	        @ID_FUNDO_CUSTODIA_2 INT

	SELECT TOP 1 @ID_FUNDO_CUSTODIA = F.ID_FUNDO
	FROM FIDC_CUSTODIA_HML.dbo.TB_FUNDO F
	WHERE F.NU_CNPJ COLLATE DATABASE_DEFAULT = @cnpj_fundo

	SELECT TOP 1 @ID_FUNDO_CUSTODIA_2 = F.ID_FUNDO
	FROM FIDC_CUSTODIA_HML_2.dbo.TB_FUNDO F
	WHERE F.NU_CNPJ COLLATE DATABASE_DEFAULT = @cnpj_fundo
	---------FIM:::: SETANDO VARIAVEIS CUTODIA 1 E 2
    
    CREATE TABLE #OP (
        ID_FUNDO                INT NOT NULL,
        DT_POSICAO              DATE NOT NULL,
        CD_CONTRATO             VARCHAR(100) NOT NULL,
        DOC_ORIGINADOR          VARCHAR(14) NULL,
        CD_SISTEMA_ORIGEM       VARCHAR(10) NOT NULL,
        TIPO                    VARCHAR(40) NOT NULL,
        DS_CONTA_COSIF          VARCHAR(100) NOT NULL,
        DT_AQUISICAO            DATE NOT NULL,
        DT_VENCIMENTO           DATE NOT NULL,
        TX_OPERACAO             NUMERIC(25, 10) NOT NULL,
        FL_COOBRIGACAO          BIT NOT NULL,
        VL_CONTRATO             NUMERIC(19, 4) NOT NULL,
        VL_NOMINAL              NUMERIC(19, 4) NOT NULL,
        VL_PERC_COOBRIGACAO     NUMERIC(10, 7) NULL,
        VL_PERC_SUBORDINACAO    NUMERIC(10, 7) NULL,
        VL_PDD                  NUMERIC(19, 4) NOT NULL,
        VL_PERC_INDEXADOR       NUMERIC(5, 2) NOT NULL,
        ID_CLIENTE              BIGINT NOT NULL,
        DOC_CLIENTE             VARCHAR(14) NOT NULL,
        DOC                     VARCHAR(14) NOT NULL,
        ID_CEDENTE              BIGINT NOT NULL,
        ID_ANEXO_02             INT NOT NULL,
        CD_ANEXO_02             VARCHAR(2) NOT NULL,
        ID_ANEXO_03             INT NOT NULL,
        CD_ANEXO_03             VARCHAR(4) NOT NULL,
        ID_ANEXO_04             INT NOT NULL,
        CD_ANEXO_04             VARCHAR(4) NOT NULL,
        ID_ANEXO_05             INT NOT NULL,
        CD_ANEXO_05             VARCHAR(2) NOT NULL,
        ID_ANEXO_06             INT NOT NULL,
        CD_ANEXO_06             VARCHAR(3) NOT NULL,
        ID_ANEXO_08             INT NULL,
        CD_ANEXO_08             VARCHAR(2) NULL,
        ID_ANEXO_17             INT NOT NULL,
        CD_ANEXO_17             VARCHAR(2) NOT NULL,
        ID_ANEXO_18             INT NOT NULL,
        CD_ANEXO_18             VARCHAR(1) NOT NULL,
        ID_ANEXO_19             INT NOT NULL,
        CD_ANEXO_19             VARCHAR(1) NOT NULL,
        ID_ANEXO_28             INT NOT NULL,
        CD_ANEXO_28             VARCHAR(2) NOT NULL,
        ID_OPERACAO             INT NULL,
        ID_XML_CLI              INT NULL,
        ID_XML_OP               INT NULL,
		NUM_CONTRATO_C3         VARCHAR(21),
		IC_BAIXAR_ATIVO         BIT NOT NULL DEFAULT 0,
		IC_RECOMPRA             BIT NOT NULL DEFAULT 0,
		VL_MOVIMENTACAO         NUMERIC(17,2),
		DT_MOVIMENTO            SMALLDATETIME,
		NM_TIPO_MOVIMENTO       VARCHAR(100)
    )
       
    CREATE NONCLUSTERED INDEX ix_op ON #OP (DOC)
    INCLUDE (DT_POSICAO,CD_CONTRATO,DS_CONTA_COSIF,DT_AQUISICAO,DT_VENCIMENTO,TX_OPERACAO,VL_CONTRATO,VL_NOMINAL,VL_PDD,VL_PERC_INDEXADOR,ID_CLIENTE,ID_ANEXO_02,ID_ANEXO_03,ID_ANEXO_04,ID_ANEXO_05,ID_ANEXO_06,ID_ANEXO_08,ID_ANEXO_17)

    INSERT INTO #OP
    SELECT 
        O.ID_FUNDO,
        DT_POSICAO,
        CD_CONTRATO,
        DOC_ORIGINADOR,
        O.CD_SISTEMA_ORIGEM,
        TIPO,
        DS_CONTA_COSIF,
        DT_AQUISICAO,
        DT_VENCIMENTO,
        TX_OPERACAO*100,
        FL_COOBRIGACAO,
        VL_CONTRATO,
        VL_NOMINAL,
        VL_PERC_COOBRIGACAO,
        VL_PERC_SUBORDINACAO,
        VL_PDD,
        VL_PERC_INDEXADOR,
        O.ID_CLIENTE,
        O.DOC_CLIENTE,
        LEFT(O.DOC_CLIENTE, CASE WHEN A11.TP_PESSOA = 'J' THEN 8 ELSE 11 END) AS DOC,
        ID_CEDENTE ,
        ID_ANEXO_02,
        CD_ANEXO_02,
        ID_ANEXO_03,
        CD_ANEXO_03,
        ID_ANEXO_04,
        CD_ANEXO_04,
        ID_ANEXO_05,
        CD_ANEXO_05,
        ID_ANEXO_06,
        CD_ANEXO_06,
        ID_ANEXO_08,
        CD_ANEXO_08,
        ID_ANEXO_17,
        CD_ANEXO_17,
        ID_ANEXO_18,
        CD_ANEXO_18,
        ID_ANEXO_19,
        CD_ANEXO_19,
        ID_ANEXO_28,
        CD_ANEXO_28,
        ID_OPERACAO,
        null,
        null,
		O.NUM_CONTRATO_C3,
		o.IC_BAIXAR_ATIVO,  
		o.IC_RECOMPRA,      
		o.VL_MOVIMENTACAO,  
		o.DT_MOVIMENTO,     
		o.NM_TIPO_MOVIMENTO
    FROM        fn_Operacao(@id_fundo, @data)   AS O
    INNER JOIN  TB_3040_BAS_CLIENTE             AS C    ON (C.ID_CLIENTE = O.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA      AS A11  ON (A11.ID_ANEXO_11 = C.ID_ANEXO_11)
      

	-- Atualização Caracteristica Especial / Necessário para informes que não geram a tag "CaracEspecial"
	UPDATE #OP SET CD_ANEXO_08 = NULL
	FROM #OP AS OP1
	INNER JOIN TB_3040_ANEXO_08_CARAC_ESPECIAL AS A08 ON A08.ID_ANEXO_08 = OP1.ID_ANEXO_08
	WHERE A08.CD_CARAC_ESPECIAL = 0 
      
    -----------------------------------------------------------------------------------------------
    -- Limpar os dados das tabelas de saída
    DELETE x FROM TB_3040_XML_INF AS x
    DELETE x FROM TB_3040_XML_GAR AS x
    DELETE o FROM TB_3040_XML_OP AS o
    DELETE c FROM TB_3040_XML_CLI AS c
    DELETE c FROM TB_3040_XML_AGREG AS c

    DELETE      d
    FROM        TB_3040_XML         AS d
    WHERE       d.CNPJ              = @cnpj_fundo
    AND         d.DTBASE            = @data
    AND         d.PARTE             = @parte
    AND         d.REMESSA           = @remessa

    -----------------------------------------------------------------------------------------------
    -- Popular as tabelas de saída
    DECLARE         @id_xml BIGINT

    INSERT INTO     TB_3040_XML (
                    CNPJ,
                    DTBASE,
                    EMAILRESP,
                    NOMERESP,
                    PARTE,
                    REMESSA,
                    TELRESP,
                    TOTALCLI,
                    TPARQ)
    SELECT          CD_CNPJ_FUNDO,
                    @data,
                    EMAIL_RESPONSAVEL,
                    NM_RESPONSAVEL,
                    @parte,
                    @remessa,
                    TEL_RESPONSAVEL,
                    0, --CALCULO DE TOTAL DE CLIENTES É FEITO POSTERIORMENTE
                    @tipo_arquivo
    FROM            TB_3040_BAS_FUNDO 
    WHERE           ID_FUNDO = @id_fundo
    
    SELECT          @id_xml = SCOPE_IDENTITY();

    ---------------------------------------------------------------------------------------------    
    CREATE TABLE #AGREGAR (
        DOC_CLIENTE                varchar(14) NOT NULL,
        CD_FAIXA_VALOR              VARCHAR(1) NOT NULL
    )

    INSERT INTO #AGREGAR
        SELECT 
                x.DOC_CLIENTE, 
                a.CD_FAIXA_VALOR
        FROM TB_3040_ANEXO_14_FAIXA_VALOR a INNER JOIN
            (           
            SELECT      
                        o.DOC
                                                                AS DOC_CLIENTE,
                        SUM(o.VL_NOMINAL)                      AS VL_NOMINAL
            FROM        #OP           AS o
            GROUP BY    o.DOC
            HAVING      SUM(o.VL_NOMINAL) <= @valor_agreg
        ) AS x ON (x.VL_NOMINAL BETWEEN a.VL_MIN AND a.VL_MAX)
   
    INSERT INTO TB_3040_XML_AGREG
    SELECT      o.CD_ANEXO_08,
                o.CD_ANEXO_17,
                o.CD_ANEXO_28,
                a.CD_FAIXA_VALOR,
                a07.CD_LOCALIZACAO,
                o.CD_ANEXO_03
                                                        AS CD_MODALIDADE,
                o.CD_ANEXO_02,
                o.CD_ANEXO_04
                                                        AS CD_ORIGEM_RECURSOS,
                SUM(o.VL_PDD)                           AS VL_PDD,
                o.CD_ANEXO_19,
                COUNT(DISTINCT o.DOC)
                                                        AS QTDCLI,
                COUNT(1)                                AS QTDOP,
                a11.CD_TP_PESSOA,
                a10.CD_TP_CONTROLE,
                NULL                                    AS V20,
                NULL                                    AS V40,
                NULL                                    AS V60,
                NULL                                    AS V80,
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 0 AND 30, o.VL_NOMINAL, 0)), 0)
                                                        AS V110,    -- Créditos a vencer até 30 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 31 AND 60, o.VL_NOMINAL, 0)), 0)
                                                        AS V120,    -- Créditos a vencer de 31 a 60 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 61 AND 90, o.VL_NOMINAL, 0)), 0)
                                                        AS V130,    -- Créditos a vencer de 61 a 90 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 91 AND 180, o.VL_NOMINAL, 0)), 0)
                                                        AS V140,    -- Créditos a vencer de 91 a 180 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 181 AND 360, o.VL_NOMINAL, 0)), 0)
                                                        AS V150,    -- Créditos a vencer de 181 a 360 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 361 AND 720, o.VL_NOMINAL, 0)), 0)
                                                        AS V160,    -- Créditos a vencer de 361 a 720 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 721 AND 1080, o.VL_NOMINAL, 0)), 0)
                                                        AS V165,    -- Créditos a vencer de 721 a 1080 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 1081 AND 1440, o.VL_NOMINAL, 0)), 0)
                                                        AS V170,    -- Créditos a vencer de 1081 a 1440 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 1441 AND 1800, o.VL_NOMINAL, 0)), 0)
                                                        AS V175,    -- Créditos a vencer de 1441 a 1800 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 1801 AND 5400, o.VL_NOMINAL, 0)), 0)
                                                        AS V180,    -- Créditos a vencer de 1801 a 5400 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) > 5400, o.VL_NOMINAL, 0)), 0)
                                                        AS V190,    -- Créditos a vencer acima de 5400 dias
                NULL                                    AS V199,
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -14 AND -1, o.VL_NOMINAL, 0)), 0)
                                                        AS V205,    -- Créditos vencidos de 1 a 14 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -30 AND -15, o.VL_NOMINAL , 0)), 0)
                                                        AS V210,    -- Créditos vencidos de 15 a 30 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -60 AND -31, o.VL_NOMINAL, 0)), 0)
                                                        AS V220,    -- Créditos vencidos de 31 a 60 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -90 AND -61, o.VL_NOMINAL, 0)), 0)
                                                        AS V230,    -- Créditos vencidos de 61 a 90 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -120 AND -91, o.VL_NOMINAL, 0)), 0)
                                                        AS V240,    -- Créditos vencidos de 91 a 120 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -150 AND -121, o.VL_NOMINAL, 0)), 0)
                                                        AS V245,    -- Créditos vencidos de 121 a 150 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -180 AND -151, o.VL_NOMINAL, 0)), 0)
                                                        AS V250,    -- Créditos vencidos de 151 a 180 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -240 AND -181, o.VL_NOMINAL, 0)), 0)
                                                        AS V255,    -- Créditos vencidos de 181 a 240 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -300 AND -241, o.VL_NOMINAL, 0)), 0)
                                                        AS V260,    -- Créditos vencidos de 241 a 300 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -360 AND -301, o.VL_NOMINAL, 0)), 0)
                                                        AS V270,    -- Créditos vencidos de 301 a 360 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -540 AND -361, o.VL_NOMINAL, 0)), 0)
                                                        AS V280,    -- Créditos vencidos de 361 a 540 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) < -540, o.VL_NOMINAL, 0)), 0)
                                                        AS V290,    -- Créditos vencidos acima de 540 dias
                NULL                                    AS V310,
                NULL                                    AS V320,
                NULL                                    AS V330,
                o.CD_ANEXO_18,
                @id_xml
    FROM        #OP           AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                     AS c    ON (c.ID_CLIENTE = o.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA              AS a11  ON (c.ID_ANEXO_11 = a11.ID_ANEXO_11)
    INNER JOIN  #AGREGAR                                 AS a    ON (o.DOC = a.DOC_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_07_LOCALIZACAO            AS a07  ON (c.ID_ANEXO_07 = a07.ID_ANEXO_07)
    INNER JOIN  TB_3040_ANEXO_10_TP_CONTROLE            AS a10  ON (c.ID_ANEXO_10 = a10.ID_ANEXO_10)
	WHERE O.IC_BAIXAR_ATIVO = 0
    GROUP BY    o.CD_ANEXO_08,
                o.CD_ANEXO_17,
                o.CD_ANEXO_28,
                a.CD_FAIXA_VALOR,
                a07.CD_LOCALIZACAO,
                o.CD_ANEXO_03,
                o.CD_ANEXO_02,
                o.CD_ANEXO_04,
                o.CD_ANEXO_19,
                a11.CD_TP_PESSOA,
                a10.CD_TP_CONTROLE,
                o.CD_ANEXO_18

--RECLASSIFICAR FAIXA DE VALOR (OPERACOES AGREGADAS)
--SOMAR VENCIMENTOS / QUANTIDADE DE OPERACAOES (CALCULO FAIXA DE VALOR)
	UPDATE TB_3040_XML_AGREG 
	SET FAIXAVLR = X.CD_FAIXA_VALOR  
		FROM TB_3040_XML_AGREG  AS A 
		INNER JOIN (
						SELECT ID_XML_AGREG, ANEXO_14.CD_FAIXA_VALOR  FROM (
																				SELECT		AG.ID_XML_AGREG ,
																						
																						SUM  (COALESCE(AG.V20,0)
																							+COALESCE(AG.V40,0)
																							+COALESCE(AG.V60,0)
																							+COALESCE(AG.V80,0)
																							+COALESCE(AG.V110,0)
																							+COALESCE(AG.V120,0)
																							+COALESCE(AG.V130,0)
																							+COALESCE(AG.V140,0)
																							+COALESCE(AG.V150,0)
																							+COALESCE(AG.V160,0)
																							+COALESCE(AG.V165,0)
																							+COALESCE(AG.V170,0)
																							+COALESCE(AG.V175,0)
																							+COALESCE(AG.V180,0)
																							+COALESCE(AG.V190,0)
																							+COALESCE(AG.V199,0)
																							+COALESCE(AG.V205,0)
																							+COALESCE(AG.V210,0)
																							+COALESCE(AG.V220,0)
																							+COALESCE(AG.V230,0)
																							+COALESCE(AG.V240,0)
																							+COALESCE(AG.V245,0)
																							+COALESCE(AG.V250,0)
																							+COALESCE(AG.V255,0)
																							+COALESCE(AG.V260,0)
																							+COALESCE(AG.V270,0)
																							+COALESCE(AG.V280,0)
																							+COALESCE(AG.V290,0)
																							+COALESCE(AG.V310,0)
																							+COALESCE(AG.V320,0)
																							+COALESCE(AG.V330,0)) / AG.QTDOP AS FAIXA
																																											
																				FROM  TB_3040_XML_AGREG AG
																				GROUP BY AG.ID_XML_AGREG, AG.QTDOP ) AS A
																				
							INNER JOIN TB_3040_ANEXO_14_FAIXA_VALOR ANEXO_14 ON ANEXO_14.VL_MIN <= A.FAIXA AND VL_MAX > A.FAIXA
		) AS X ON X.ID_XML_AGREG = A.ID_XML_AGREG

		
-- RECLASSIFICAR DESEMPENHO DA OPERAÇÃO
 UPDATE TB_3040_XML_AGREG 
	SET DESEMPOP = X.DESEMPENHO
		FROM TB_3040_XML_AGREG  AS A
INNER JOIN (

 SELECT ID_XML,
		ID_XML_AGREG,
 CASE 
	WHEN	V240 IS NOT NULL Or 	V245 IS NOT NULL or 	V250 IS NOT NULL or 	V255 IS NOT NULL  Or 	V260 IS NOT NULL  or 	V270 IS NOT NULL  
			or 	V280 IS NOT NULL  or 	V290 IS NOT NULL  or 	V310 IS NOT NULL or 	V320 IS NOT NULL or 	V330 IS NOT NULL THEN 05  
ELSE
	CASE 
		WHEN	V230 IS NOT NULL THEN 04 
	ELSE
		CASE 
			WHEN	V220 IS NOT NULL THEN 03
		ELSE
				CASE 
					WHEN	V210 IS NOT NULL THEN 02
				ELSE
					CASE 
						WHEN	V205 IS NOT NULL THEN 01 --RUBEM COLOCOU O "01" NO DIA 20/02/2020,
					ELSE 
				
					
						CASE    		 
						WHEN	V20 IS NOT NULL  or	V40 IS NOT NULL  or V60 IS NOT NULL   or 	V80 IS NOT NULL   or 	V110 IS NOT NULL or 	V120 IS NOT NULL or 	V130 IS NOT NULL or 	V140 IS NOT NULL  	or 	V150 IS NOT NULL  
								or 	V160 IS NOT NULL  or 	V165 IS NOT NULL  or 	V170 IS NOT NULL  or 	V175 IS NOT NULL  or 	V180 IS NOT NULL  or 	V190 IS NOT NULL  or 	V199 IS NOT NULL THEN 01 

END
	END
		END
			END
				END
					END  as DESEMPENHO 


FROM TB_3040_XML_AGREG ) AS X ON X.ID_XML_AGREG = A.ID_XML_AGREG AND X.ID_XML = A.ID_XML



    DELETE FROM #OP WHERE DOC IN (SELECT DOC_CLIENTE FROM #AGREGAR)
    
    TRUNCATE TABLE #AGREGAR
    DROP TABLE #AGREGAR
            
    ---------------------------------------------------------------------------------------------
    INSERT INTO TB_3040_XML_CLI
    SELECT      DISTINCT
                a20.CD_AUTORIZACAO                  AS CD_AUTORIZACAO,
                --LEFT(o.DOC, 8)   					AS DOC_CLIENTE,--OS CLIENTES COM CNPJ ERAM RETIRADOS DA CONSULTA, FEITO AJUSTE
				LEFT(O.DOC, CASE WHEN A11.TP_PESSOA = 'J' THEN 8 ELSE 11 END) AS DOC_CLIENTE, 
                a16.CD_CLASS_RISCO_CLI,
                c.CONG_ECONOMICO,
                c.VL_FAT_ANUAL,
                MIN(c.DT_INI_RELAC) AS DT_INI_RELAC,
                IIF(a11.TP_PESSOA = 'J', a24.CD_PORTE_CLIENTE, a25.CD_PORTE_CLIENTE),
                a11.CD_TP_PESSOA,
                IIF(a11.TP_PESSOA = 'J', a10.CD_TP_CONTROLE, NULL),
                @id_xml
    FROM        #OP       AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS c    ON (c.id_cliente = o.id_cliente)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA          AS a11  ON (c.ID_ANEXO_11 = a11.ID_ANEXO_11)
    INNER JOIN  TB_3040_ANEXO_20_AUTORIZACAO        AS a20  ON (c.ID_ANEXO_20 = a20.ID_ANEXO_20)
    INNER JOIN  TB_3040_ANEXO_16_CLASS_RISCO_CLI    AS a16  ON (c.ID_ANEXO_16 = a16.ID_ANEXO_16)
    INNER JOIN  TB_3040_ANEXO_10_TP_CONTROLE        AS a10  ON (c.ID_ANEXO_10 = a10.ID_ANEXO_10)
    LEFT JOIN   TB_3040_ANEXO_24_PORTE_CLIENTE_PJ   AS a24  ON (c.ID_ANEXO_24 = a24.ID_ANEXO_24)
    LEFT JOIN   TB_3040_ANEXO_25_PORTE_CLIENTE_PF   AS a25  ON (c.ID_ANEXO_25 = a25.ID_ANEXO_25)
    GROUP BY    a20.CD_AUTORIZACAO,
                LEFT(O.DOC, CASE WHEN A11.TP_PESSOA = 'J' THEN 8 ELSE 11 END),
                --o.DOC,
                a16.CD_CLASS_RISCO_CLI,
                c.CONG_ECONOMICO,
                c.VL_FAT_ANUAL,
                IIF(a11.TP_PESSOA = 'J', a24.CD_PORTE_CLIENTE, a25.CD_PORTE_CLIENTE),
                a11.CD_TP_PESSOA,
                IIF(a11.TP_PESSOA = 'J', a10.CD_TP_CONTROLE, NULL)
	--HAVING      SUM(o.VL_NOMINAL) > @valor_agreg   --RUBEM TIROU NO DIA 26/02/2020
    --HAVING      SUM(o.VL_CONTRATO) > @valor_agreg --RUBEM TIROU NO DIA 20/02/2020

    --Atualiza o total de clientes
    UPDATE TB_3040_XML SET TOTALCLI = (SELECT COUNT(1) FROM TB_3040_XML_CLI WHERE ID_XML = @id_xml)
    WHERE ID_XML = @id_xml

    UPDATE #OP set ID_XML_CLI = c.ID_XML_CLI
    FROM #OP as o
    inner join TB_3040_XML_CLI as c on (c.CD = o.DOC COLLATE DATABASE_DEFAULT)

    ------------------------------------------ OPERAÇÕES DE AQUISIÇÕES (ENTRADAS)
    INSERT INTO TB_3040_XML_OP
    SELECT      IIF(o.CD_ANEXO_08='00', NULL,o.CD_ANEXO_08)             AS CARACESPECIAL, 						-- ALTERAÇÃO TIAGO 28/04/2020 
                c.CEP                                   AS CEP,
                o.CD_ANEXO_17                 AS CLASSOP,
                o.CD_CONTRATO                           AS CONTRT,
                o.DS_CONTA_COSIF                        AS COSIF,
                IIF(a11.TP_PESSOA = 'J', c.DOC_CLIENTE, NULL)
                                                        AS DETCLI,
                NULLIF(MAX(IIF(o.DT_VENCIMENTO < o.DT_POSICAO, ABS(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO)), -1)), -1)
                                                        AS DIAATRASO,
														
                o.DT_AQUISICAO 						    AS DTCONTR,												-- ALTERAÇÃO TIAGO 28/04/2020 
                IIF(MAX(o.DT_VENCIMENTO) >= o.DT_AQUISICAO, MAX(o.DT_VENCIMENTO), o.DT_AQUISICAO) AS DTVENCOP, 	-- SE DT_VENCIMENTO for menor que a DT_AQUISICAO a DTVENCOP será igual a DT_AQUISICAO - ALTERAÇÃO TIAGO 28/04/2020
                
                o.CD_ANEXO_05   AS INDX,
                o.CD_ANEXO_03
                                                        AS MOD,
                o.CD_ANEXO_02                        AS NATUOP,
                (SELECT CD_ORIGEM_RECURSOS + CD_SUB_ORIGEM_RECURSOS FROM TB_3040_ANEXO_04_ORIGEM_RECURSO AS a04 WHERE o.ID_ANEXO_04 = a04.ID_ANEXO_04)
                                                        AS ORIGEMREC,
                o.VL_PERC_INDEXADOR                     AS PERCINDX,
                SUM(o.VL_PDD)                           AS PROVCONSTTD,
                IIF(o.TX_OPERACAO < 10000.0, o.TX_OPERACAO, 9999.9999999)
                                                        AS TAXEFT,
                o.CD_ANEXO_06                           AS VARCAMB,
                NULL                                    AS V20,
                NULL                                    AS V40,
                NULL                                    AS V60,
                NULL                                    AS V80,
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 0 AND 30, o.VL_NOMINAL, 0)), 0)
                                                        AS V110,    -- Créditos a vencer até 30 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 31 AND 60, o.VL_NOMINAL, 0)), 0)
                                                        AS V120,    -- Créditos a vencer de 31 a 60 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 61 AND 90, o.VL_NOMINAL, 0)), 0)
                                                        AS V130,    -- Créditos a vencer de 61 a 90 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 91 AND 180, o.VL_NOMINAL, 0)), 0)
                                                        AS V140,    -- Créditos a vencer de 91 a 180 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 181 AND 360, o.VL_NOMINAL, 0)), 0)
                                                        AS V150,    -- Créditos a vencer de 181 a 360 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 361 AND 720, o.VL_NOMINAL, 0)), 0)
                                                        AS V160,    -- Créditos a vencer de 361 a 720 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 721 AND 1080, o.VL_NOMINAL, 0)), 0)
                                                        AS V165,    -- Créditos a vencer de 721 a 1080 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 1081 AND 1440, o.VL_NOMINAL, 0)), 0)
                                                        AS V170,    -- Créditos a vencer de 1081 a 1440 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 1441 AND 1800, o.VL_NOMINAL, 0)), 0)
                                                        AS V175,    -- Créditos a vencer de 1441 a 1800 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN 1801 AND 5400, o.VL_NOMINAL, 0)), 0)
                                                        AS V180,    -- Créditos a vencer de 1801 a 5400 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) > 5400, o.VL_NOMINAL, 0)), 0)
                                                        AS V190,    -- Créditos a vencer acima de 5400 dias
                NULL                                    AS V199,
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -14 AND -1, o.VL_NOMINAL, 0)), 0)
                                                        AS V205,    -- Créditos vencidos de 1 a 14 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -30 AND -15, o.VL_NOMINAL, 0)), 0)
                                                        AS V210,    -- Créditos vencidos de 15 a 30 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -60 AND -31, o.VL_NOMINAL, 0)), 0)
                                                        AS V220,    -- Créditos vencidos de 31 a 60 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -90 AND -61, o.VL_NOMINAL, 0)), 0)
                                                        AS V230,    -- Créditos vencidos de 61 a 90 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -120 AND -91, o.VL_NOMINAL, 0)), 0)
                                                        AS V240,    -- Créditos vencidos de 91 a 120 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -150 AND -121, o.VL_NOMINAL, 0)), 0)
                                                        AS V245,    -- Créditos vencidos de 121 a 150 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -180 AND -151, o.VL_NOMINAL, 0)), 0)
                                                        AS V250,    -- Créditos vencidos de 151 a 180 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -240 AND -181, o.VL_NOMINAL, 0)), 0)
                                                        AS V255,    -- Créditos vencidos de 181 a 240 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -300 AND -241, o.VL_NOMINAL, 0)), 0)
                                                        AS V260,    -- Créditos vencidos de 241 a 300 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -360 AND -301, o.VL_NOMINAL, 0)), 0)
                                                        AS V270,    -- Créditos vencidos de 301 a 360 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) BETWEEN -540 AND -361, o.VL_NOMINAL, 0)), 0)
                                                        AS V280,    -- Créditos vencidos de 361 a 540 dias
                NULLIF(SUM(IIF(DATEDIFF(dd, o.DT_POSICAO, o.DT_VENCIMENTO) < -540, o.VL_NOMINAL, 0)), 0)
                                                        AS V290,    -- Créditos vencidos acima de 540 dias
                NULL                                    AS V310,
                NULL                                    AS V320,
                NULL                                    AS V330,
                SUM(o.VL_CONTRATO)                      AS VLRCONTR,
                O.ID_XML_CLI							AS ID_XML_CLI,
				NULL                    AS DTAPROXPARCELA,
                NULL                    AS VLRPROXPARCELA,
				NULL                    AS QTDPARCELAS,
				LEFT(@CNPJ_FUNDO,8)	+ O.CD_ANEXO_03 + CONVERT(VARCHAR(14),C.CD_TP_PESSOA )
				 + CASE WHEN C.CD_TP_PESSOA = 1 THEN RIGHT(C.DOC_CLIENTE,11)
					    WHEN C.CD_TP_PESSOA = 2 THEN LEFT (C.DOC_CLIENTE,8)
					    WHEN C.CD_TP_PESSOA > 2 THEN REPLICATE('0',14 - LEN(C.DOC_CLIENTE) ) + C.DOC_CLIENTE
				  END + (O.CD_CONTRATO)   AS IPOC,
				CONVERT(BIT, 0)         AS IS_BAIXA
    FROM        #OP           AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                     AS c    ON (o.ID_CLIENTE = c.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA              AS a11  ON (c.ID_ANEXO_11 = a11.ID_ANEXO_11)
    WHERE       O.ID_XML_CLI IS NOT NULL        
	AND         O.IC_BAIXAR_ATIVO = 0
    GROUP BY    o.CD_ANEXO_08,
                c.CEP,
                o.CD_ANEXO_17,
                o.CD_CONTRATO,
                o.DS_CONTA_COSIF,
                IIF(a11.TP_PESSOA = 'J', c.DOC_CLIENTE, NULL),
                o.DT_AQUISICAO,
                o.CD_ANEXO_05,
                o.CD_ANEXO_03,
                o.CD_ANEXO_02,
                o.ID_ANEXO_04,
                o.VL_PERC_INDEXADOR,
                o.TX_OPERACAO,
                o.CD_ANEXO_06,
                o.ID_XML_CLI,
                C.CD_TP_PESSOA,
				C.DOC_CLIENTE

    ------------------------------------------ OPERAÇÕES DE BAIXAS (SAIDAS)
    INSERT INTO TB_3040_XML_OP
    SELECT      IIF(o.CD_ANEXO_08='00', NULL,o.CD_ANEXO_08)   AS CARACESPECIAL, 						-- ALTERAÇÃO TIAGO 28/04/2020 
                c.CEP                                         AS CEP,
                o.CD_ANEXO_17                                 AS CLASSOP,
                o.CD_CONTRATO                                 AS CONTRT,
                o.DS_CONTA_COSIF                              AS COSIF,
                IIF(a11.TP_PESSOA = 'J', c.DOC_CLIENTE, NULL) AS DETCLI,
                NULL                                          AS DIAATRASO,
                o.DT_AQUISICAO 						          AS DTCONTR,												-- ALTERAÇÃO TIAGO 28/04/2020 
                NULL                                          AS DTVENCOP, 	
				o.CD_ANEXO_05                                 AS INDX,
                o.CD_ANEXO_03                                 AS MOD,
                o.CD_ANEXO_02                                 AS NATUOP,
                (SELECT CD_ORIGEM_RECURSOS + CD_SUB_ORIGEM_RECURSOS 
				 FROM TB_3040_ANEXO_04_ORIGEM_RECURSO AS a04 
				 WHERE o.ID_ANEXO_04 = a04.ID_ANEXO_04)
                                                                          AS ORIGEMREC,
                o.VL_PERC_INDEXADOR                                       AS PERCINDX,
                NULL                                                      AS PROVCONSTTD,
                IIF(o.TX_OPERACAO < 10000.0, o.TX_OPERACAO, 9999.9999999) AS TAXEFT,
                o.CD_ANEXO_06                                             AS VARCAMB,
                NULL                                                      AS V20,
                NULL                                                      AS V40,
                NULL                                                      AS V60,
                NULL                                                      AS V80,
                NULL                                                      AS V110,    -- Créditos a vencer até 30 dias
                NULL                                                      AS V120,    -- Créditos a vencer de 31 a 60 dias
                NULL                                                      AS V130,    -- Créditos a vencer de 61 a 90 dias
                NULL                                                      AS V140,    -- Créditos a vencer de 91 a 180 dias
                NULL                                                      AS V150,    -- Créditos a vencer de 181 a 360 dias
                NULL                                                      AS V160,    -- Créditos a vencer de 361 a 720 dias
                NULL                                                      AS V165,    -- Créditos a vencer de 721 a 1080 dias
                NULL                                                      AS V170,    -- Créditos a vencer de 1081 a 1440 dias
                NULL                                                      AS V175,    -- Créditos a vencer de 1441 a 1800 dias
                NULL                                                      AS V180,    -- Créditos a vencer de 1801 a 5400 dias
                NULL                                                      AS V190,    -- Créditos a vencer acima de 5400 dias
                NULL                                                      AS V199,
                NULL                                                      AS V205,    -- Créditos vencidos de 1 a 14 dias
                NULL                                                      AS V210,    -- Créditos vencidos de 15 a 30 dias
                NULL                                                      AS V220,    -- Créditos vencidos de 31 a 60 dias
                NULL                                                      AS V230,    -- Créditos vencidos de 61 a 90 dias
                NULL                                                      AS V240,    -- Créditos vencidos de 91 a 120 dias
                NULL                                                      AS V245,    -- Créditos vencidos de 121 a 150 dias
                NULL                                                      AS V250,    -- Créditos vencidos de 151 a 180 dias
                NULL                                                      AS V255,    -- Créditos vencidos de 181 a 240 dias
                NULL                                                      AS V260,    -- Créditos vencidos de 241 a 300 dias
                NULL                                                      AS V270,    -- Créditos vencidos de 301 a 360 dias
                NULL                                                      AS V280,    -- Créditos vencidos de 361 a 540 dias
                NULL                                                      AS V290,    -- Créditos vencidos acima de 540 dias
                NULL                                                      AS V310,
                NULL                                                      AS V320,
                NULL                                                      AS V330,
                NULL                                                      AS VLRCONTR,
                O.ID_XML_CLI							                  AS ID_XML_CLI,
				NULL                                                      AS IPOC,
                NULL                                                      AS DTAPROXPARCELA,
                NULL                                                      AS QTDPARCELAS,
                NULL                                                      AS VLRPROXPARCELA,
				CONVERT(BIT, 1)                                           AS IS_BAIXA
    FROM        #OP           AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                     AS c    ON (o.ID_CLIENTE = c.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA              AS a11  ON (c.ID_ANEXO_11 = a11.ID_ANEXO_11)
    WHERE       O.ID_XML_CLI IS NOT NULL        
	AND         O.IC_BAIXAR_ATIVO = 1
    GROUP BY    o.CD_ANEXO_08,
                c.CEP,
                o.CD_ANEXO_17,
                o.CD_CONTRATO,
                o.DS_CONTA_COSIF,
                IIF(a11.TP_PESSOA = 'J', c.DOC_CLIENTE, NULL),
                o.DT_AQUISICAO,
                o.CD_ANEXO_05,
                o.CD_ANEXO_03,
                o.CD_ANEXO_02,
                o.ID_ANEXO_04,
                o.VL_PERC_INDEXADOR,
                o.TX_OPERACAO,
                o.CD_ANEXO_06,
                o.ID_XML_CLI,
				C.CD_TP_PESSOA,
				C.DOC_CLIENTE

    UPDATE #OP set ID_XML_OP = c.ID_XML_OP
    FROM #OP as o
    inner join TB_3040_XML_OP as c on (c.CONTRT = o.CD_CONTRATO COLLATE DATABASE_DEFAULT)
    -----------------------------------------------------------------------------------------------

	--ATUALIZANDO OS VALORES REFERENTE A PROXPARCELA NA TB TB_3040_XML_OP
	CREATE TABLE #PARCELAS(VL_NOMINAL	NUMERIC(19,4),
	                       NU_PARCELA SMALLINT,
						   DT_VENCIMENTO	DATE,
						   DS_NU_DOCUMENTO	VARCHAR(25),
						   DS_SEU_NUMERO	VARCHAR(25))

	IF(@ID_FUNDO_CUSTODIA IS NOT NULL)
	BEGIN
		
		INSERT #PARCELAS
		SELECT O.VL_NOMINAL,R.NU_PARCELA, O.DT_VENCIMENTO, R.DS_NU_DOCUMENTO COLLATE DATABASE_DEFAULT, R.DS_SEU_NUMERO COLLATE DATABASE_DEFAULT
		FROM TB_3040_BAS_OPERACAO O
		INNER JOIN    FIDC_CUSTODIA_HML.DBO.TB_RECEBIVEL R ON (R.DS_NU_DOCUMENTO COLLATE DATABASE_DEFAULT = O.DS_NU_DOCUMENTO 
		                                                   AND R.DS_SEU_NUMERO COLLATE DATABASE_DEFAULT = O.CD_CONTRATO_CEDENTE)
		WHERE R.ID_FUNDO = @ID_FUNDO_CUSTODIA
		GROUP BY O.VL_NOMINAL,R.NU_PARCELA, O.DT_VENCIMENTO,R.DS_NU_DOCUMENTO, R.DS_SEU_NUMERO
		ORDER BY R.DS_NU_DOCUMENTO, R.NU_PARCELA ASC

	END
	ELSE
	BEGIN

		INSERT #PARCELAS
		SELECT O.VL_NOMINAL,R.NU_PARCELA, O.DT_VENCIMENTO, R.DS_NU_DOCUMENTO COLLATE DATABASE_DEFAULT, R.DS_SEU_NUMERO COLLATE DATABASE_DEFAULT
		FROM TB_3040_BAS_OPERACAO O
		INNER JOIN    FIDC_CUSTODIA_HML_2.DBO.TB_RECEBIVEL R ON (R.DS_NU_DOCUMENTO COLLATE DATABASE_DEFAULT = O.DS_NU_DOCUMENTO 
		                                                     AND R.DS_SEU_NUMERO COLLATE DATABASE_DEFAULT = O.CD_CONTRATO_CEDENTE)
        WHERE R.ID_FUNDO = @ID_FUNDO_CUSTODIA_2
		GROUP BY O.VL_NOMINAL,R.NU_PARCELA, O.DT_VENCIMENTO,R.DS_NU_DOCUMENTO, R.DS_SEU_NUMERO
		ORDER BY R.DS_NU_DOCUMENTO, R.NU_PARCELA ASC

	END

	WHILE EXISTS(SELECT TOP 1 * FROM #PARCELAS)
	BEGIN
		
		DECLARE @PARCELAATUAL INT , @PROXPARCELA INT, @NUDOC VARCHAR(100), @QTDEPARCELAS INT, @SEUNUMERO VARCHAR(100)
		SELECT TOP 1
			@PARCELAATUAL = NU_PARCELA,
			@NUDOC = DS_NU_DOCUMENTO,
			@SEUNUMERO = DS_SEU_NUMERO
		FROM #PARCELAS
		ORDER BY DS_NU_DOCUMENTO,NU_PARCELA ASC

		SET @QTDEPARCELAS =(SELECT COUNT(*) FROM TB_3040_BAS_OPERACAO WHERE DS_NU_DOCUMENTO = @NUDOC)

		SET @PROXPARCELA = @PARCELAATUAL + 1

		IF EXISTS(SELECT TOP 1 * FROM #PARCELAS WHERE DS_NU_DOCUMENTO = @NUDOC AND NU_PARCELA = @PROXPARCELA)
		BEGIN
			
			UPDATE TB_3040_XML_OP SET DTAPROXPARCELA = DT_VENCIMENTO,
									  QTDPARCELAS = @QTDEPARCELAS,
									  VLRPROXPARCELA = VL_NOMINAL
			FROM (SELECT * FROM #PARCELAS WHERE DS_NU_DOCUMENTO = @NUDOC AND NU_PARCELA = @PROXPARCELA) P
			WHERE CONTRT = @SEUNUMERO
					
		END

		DELETE FROM #PARCELAS WHERE DS_NU_DOCUMENTO = @NUDOC AND NU_PARCELA = @PARCELAATUAL
		
	END
	DROP TABLE #PARCELAS

    -----------------------------------------------------------------------------------------------
    -- Insere as informações adicionais para cada uma das operações
    -- Insere informações adicionais para fundos sem retenção substâncial de risco
    INSERT INTO TB_3040_XML_INF
    SELECT      DISTINCT
	            CONVERT(VARCHAR, DT_AQUISICAO, 120) AS CODIGO,
                CASE    WHEN o.CD_ANEXO_02 = '04' AND 1=1 THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11)) 
                        WHEN o.CD_ANEXO_02 = '04' AND 1=0 THEN NULL -- Identificar retenção por aquisicao de cota
                        WHEN o.CD_ANEXO_02 = '02' THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
                        WHEN o.CD_ANEXO_02 = '03' THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
						WHEN o.CD_ANEXO_02 = '15' THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
						WHEN o.CD_ANEXO_02 = '12' THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
						WHEN o.CD_ANEXO_02 = '16' THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
						WHEN o.CD_ANEXO_02 = '05' THEN LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
						--WHEN o.CD_ANEXO_02 = '15' AND 1=1 THEN NULL -- Identificar retenção por aquisicao de cota  
                END
                                                    AS IDENTIFICACAO,
                CASE    WHEN o.CD_ANEXO_02 = '04' AND 1=1 THEN o.VL_PERC_COOBRIGACAO
                        WHEN o.CD_ANEXO_02 = '04' AND 1=0 THEN o.VL_PERC_SUBORDINACAO -- Identificar retenção por aquisicao de cota
                        WHEN o.CD_ANEXO_02 = '02' THEN o.VL_PERC_COOBRIGACAO
                        WHEN o.CD_ANEXO_02 = '03' THEN o.VL_PERC_COOBRIGACAO
						WHEN o.CD_ANEXO_02 = '05' THEN 0.01
						WHEN o.CD_ANEXO_02 = '15' THEN o.VL_PERC_COOBRIGACAO
						WHEN o.CD_ANEXO_02 = '16' THEN 1.0
						WHEN o.CD_ANEXO_02 = '12' THEN 1.0
						--WHEN o.CD_ANEXO_02 = '15' AND 1=0 THEN o.VL_PERC_SUBORDINACAO -- Identificar retenção por aquisicao de cota
                END
                                                    AS PERCENTUAL,
                NULL                                AS QUANTIDADE,
                CASE    WHEN o.CD_ANEXO_02 = '04' AND 1=1 THEN '0101'
                        WHEN o.CD_ANEXO_02 = '04' AND 1=0 THEN '0105' -- Identificar retenção por aquisicao de cota
                        WHEN o.CD_ANEXO_02 = '02' THEN '1001'
                        WHEN o.CD_ANEXO_02 = '03' THEN '1002'
						WHEN o.CD_ANEXO_02 = '16' THEN '1003'
						WHEN o.CD_ANEXO_02 = '12' THEN '1003' --Alterado em 17/04 solicitado por Gisele
						WHEN o.CD_ANEXO_02 = '15' THEN '0702' --Alterado em 17/04 solicitado por Gisele
						WHEN o.CD_ANEXO_02 = '05' THEN '0701'
						WHEN o.CD_ANEXO_02 = '15' THEN '0703' 
		        END 
				                                          AS ANEXO_26,
                SUM(o.VL_CONTRATO)                        AS VALOR,
                o.ID_XML_OP
    FROM        #OP       AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS d    ON (o.ID_CEDENTE = d.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA          AS a11  ON (d.ID_ANEXO_11 = a11.ID_ANEXO_11)
    WHERE       o.ID_XML_OP is not null
	AND         O.IC_BAIXAR_ATIVO = 0
    AND         ((o.CD_ANEXO_02 = '04')
    OR          (o.CD_ANEXO_02 = '02')
    OR          (o.CD_ANEXO_02 = '03')
	OR          (o.CD_ANEXO_02 = '16')
	OR          (o.CD_ANEXO_02 = '12')
	OR          (o.CD_ANEXO_02 = '05')
	OR          (O.CD_ANEXO_02 = '15'))
    GROUP BY    o.DT_AQUISICAO, 
                o.CD_ANEXO_02, 
                LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11)),
                o.VL_PERC_COOBRIGACAO,
                o.VL_PERC_SUBORDINACAO,
                o.ID_XML_OP
	
    -------------------SAIDAS-----------------------------------------------------------------------
	INSERT INTO TB_3040_XML_INF
    SELECT      NULL                                                 AS CODIGO,
                NULL                                                 AS IDENTIFICACAO,
                NULL                                                 AS PERCENTUAL,
                NULL                                                 AS QUANTIDADE,
                CASE WHEN O.NM_TIPO_MOVIMENTO = 'Prestação de garantias encerrada'
				     THEN '0315' --'Prestação de garantias encerrada'
					 WHEN O.NM_TIPO_MOVIMENTO = 'Cancelamento de contrato'
				     THEN '0310' --'Cancelamento de contrato'
					 WHEN O.NM_TIPO_MOVIMENTO = 'Baixa de limite de identificação'
				     THEN '0308' --'Baixa de limite de identificação'
					 WHEN O.NM_TIPO_MOVIMENTO = 'Operações em prejuízo baixadas do contábil'
				     THEN '0306' --'Operações em prejuízo baixadas do contábil'
				     WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 0 AND O.DT_MOVIMENTO >= O.DT_VENCIMENTO 
				     THEN '0301' -- Operação paga       
					 WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 0 AND O.DT_MOVIMENTO < O.DT_VENCIMENTO 
					 THEN '0302' --Operação liquidada antecipadamente
					 WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 1
					 THEN '0309' --Recompra de operações cedidas
					 ELSE '0399'
				END	                                                 AS ANEXO_26,
                CASE WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 1
				THEN SUM(O.VL_MOVIMENTACAO) --Recompra de operações cedidas
				     ELSE NULL                                
				END                                                  AS VALOR,
                O.ID_XML_OP                                          AS ID_XML_OP
    FROM        #OP                                 AS O
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS D    ON (O.ID_CEDENTE = D.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA          AS A11  ON (D.ID_ANEXO_11 = A11.ID_ANEXO_11)
    WHERE       O.ID_XML_OP IS NOT NULL
    AND         O.IC_BAIXAR_ATIVO = 1
    GROUP BY O.ID_XML_OP,
	         CASE WHEN O.NM_TIPO_MOVIMENTO = 'Prestação de garantias encerrada'
			     THEN '0315' --'Prestação de garantias encerrada'
				 WHEN O.NM_TIPO_MOVIMENTO = 'Cancelamento de contrato'
			     THEN '0310' --'Cancelamento de contrato'
				 WHEN O.NM_TIPO_MOVIMENTO = 'Baixa de limite de identificação'
			     THEN '0308' --'Baixa de limite de identificação'
				 WHEN O.NM_TIPO_MOVIMENTO = 'Operações em prejuízo baixadas do contábil'
			     THEN '0306' --'Operações em prejuízo baixadas do contábil'
			     WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 0 AND O.DT_MOVIMENTO >= O.DT_VENCIMENTO 
			     THEN '0301' -- Operação paga       
				 WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 0 AND O.DT_MOVIMENTO < O.DT_VENCIMENTO 
				 THEN '0302' --Operação liquidada antecipadamente
				 WHEN O.IC_BAIXAR_ATIVO = 1 AND O.IC_RECOMPRA = 1
				 THEN '0309' --Recompra de operações cedidas
				 ELSE '0399'
			 END,
			 O.IC_BAIXAR_ATIVO,
			 O.IC_RECOMPRA

    -------------------DADOS DO CONTRATO C3 - SE FOR DIFERENTE DE NULL PARA FUNDOS C3---------------
	INSERT INTO TB_3040_XML_INF
    SELECT      CONVERT(VARCHAR(21), O.NUM_CONTRATO_C3)              AS CODIGO,
                NULL                                                 AS IDENTIFICACAO,
                NULL                                                 AS PERCENTUAL,
                NULL                                                 AS QUANTIDADE,
                '0403'                                               AS ANEXO_26,
                NULL                                                 AS VALOR,
                O.ID_XML_OP                                          AS ID_XML_OP
    FROM        #OP                                 AS O
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS D    ON (O.ID_CEDENTE = D.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA          AS A11  ON (D.ID_ANEXO_11 = A11.ID_ANEXO_11)
    WHERE       O.ID_XML_OP IS NOT NULL
    AND         O.NUM_CONTRATO_C3 IS NOT NULL
	AND         O.IC_BAIXAR_ATIVO = 0
    GROUP BY    O.ID_XML_OP,
				O.NUM_CONTRATO_C3

    -----------------------------------------------------------------------------------------------
	INSERT INTO TB_3040_XML_INF
    SELECT      CONVERT(VARCHAR, DT_AQUISICAO, 120) AS CODIGO,
                LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
                                                    AS IDENTIFICACAO,
                o.VL_PERC_COOBRIGACAO
                                                    AS PERCENTUAL,
                NULL                                AS QUANTIDADE,
                '1202'
				                                          AS ANEXO_26,
                SUM(o.VL_CONTRATO)                        AS VALOR,
                o.ID_XML_OP
    FROM        #OP       AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS d    ON (o.ID_CEDENTE = d.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA          AS a11  ON (d.ID_ANEXO_11 = a11.ID_ANEXO_11)
    WHERE       o.ID_XML_OP is not null
	AND         O.IC_BAIXAR_ATIVO = 0
    AND         (O.CD_ANEXO_02 = '15')
    GROUP BY    o.DT_AQUISICAO, 
                o.CD_ANEXO_02, 
                LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11)),
                o.VL_PERC_COOBRIGACAO,
                o.VL_PERC_SUBORDINACAO,
                o.ID_XML_OP
	
    -----------------------------------------------------------------------------------------------
 	INSERT INTO TB_3040_XML_INF
    SELECT      CONVERT(VARCHAR, DT_AQUISICAO, 120) AS CODIGO,
                LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11))
                                                    AS IDENTIFICACAO,
                1.00
                                                    AS PERCENTUAL,
                NULL                                AS QUANTIDADE,
                '1201'
				                                          AS ANEXO_26,
                SUM(o.VL_CONTRATO)                        AS VALOR,
                o.ID_XML_OP
    FROM        #OP       AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS d    ON (o.ID_CEDENTE = d.ID_CLIENTE)
    INNER JOIN  TB_3040_ANEXO_11_TP_PESSOA          AS a11  ON (d.ID_ANEXO_11 = a11.ID_ANEXO_11)
	inner join  TB_3040_XML_OP                      as c on (c.CONTRT = o.CD_CONTRATO COLLATE DATABASE_DEFAULT
	                                                   AND C.ID_XML_OP = O.ID_XML_OP)
    WHERE o.ID_XML_OP is not null 
    AND   (O.CD_ANEXO_02 = '15')
	AND    O.CD_ANEXO_03 IN('1511','1512','2001','2002') --RUBEM COLOCOU NO DIA 20/02/2020, [SCR2] ERRO: Regra C35: "Se e somente se" o atributo 'Mod' for igual a '1511','1512','2001' ou '2002' , será requerida a informação adicional 'Tp' igual a '1201'. - (Elemento = 'Op', Remessa = 1, Parte = 1, Linha Arquivo XML = 3).
                                                         --RUBEM COLOCOU NO DIA 20/02/2020, [SCR2] ERRO: Regra C43: Se o valor do atributo 'Tp' da tag 'Inf' for '1201' o atributo 'Ident' da tag 'Inf' deve ser uma Modalidade, conforme valores do anexo 3 do Leiaute do doc.3040 - (Elemento 'Contrt', Remessa = 1, Parte = 1, Linha Arquivo XML = 3).
    AND         O.IC_BAIXAR_ATIVO = 0
    GROUP BY    o.DT_AQUISICAO, 
                o.CD_ANEXO_02, 
                LEFT(d.DOC_CLIENTE, IIF(a11.TP_PESSOA = 'J', 8, 11)),
                o.VL_PERC_COOBRIGACAO,
                o.VL_PERC_SUBORDINACAO,
                o.ID_XML_OP

    ---------------------------------------------------------------------------------------------
    INSERT INTO TB_3040_XML_GAR
    SELECT      g.DT_REAVALIACAO, 
                g.DS_GARANTIDOR, 
                g.VL_PERC_GARANTIDO, 
                an12.CD_GARANTIA + an12.CD_SUB_GARANTIA,
                g.VL_REAVALIACAO, 
                g.VL_ORIGINAL, 
                o.ID_XML_OP
    FROM        #OP                                 AS o
    INNER JOIN  TB_3040_BAS_CLIENTE                 AS c    ON (o.ID_CLIENTE = c.ID_CLIENTE) 
    INNER JOIN  TB_3040_BAS_GARANTIA                AS g    ON (    (   o.ID_OPERACAO IS NOT NULL 
                                                                    AND g.ID_OPERACAO = o.ID_OPERACAO) 
                                                                OR  (   o.ID_OPERACAO IS NULL
                                                                    AND (g.CD_CONTRATO_CEDENTE = o.CD_CONTRATO COLLATE DATABASE_DEFAULT)
                                                                    AND (G.CD_SISTEMA_ORIGEM = o.CD_SISTEMA_ORIGEM COLLATE DATABASE_DEFAULT)
                                                                    AND G.ID_FUNDO = o.ID_FUNDO
                                                                    AND G.DT_POSICAO = O.DT_POSICAO))
    INNER JOIN  TB_3040_ANEXO_12_GARANTIAS          AS an12 ON (an12.ID_ANEXO_12 = g.ID_ANEXO_12)
    WHERE       o.ID_XML_OP is not null
    AND         O.IC_BAIXAR_ATIVO = 0
    
    TRUNCATE TABLE #OP
    DROP TABLE #OP

	-- VARIAVEL PARA GERACAO DO XML
    DECLARE @XML XML

			SET @XML = (
			SELECT LEFT(CONVERT(VARCHAR,DtBase,120),7) AS DtBase,LEFT(CNPJ,8) AS CNPJ,Remessa,Parte,TpArq,NomeResp COLLATE SQL_LATIN1_GENERAL_CP1253_CI_AI AS NomeResp,EmailResp,TelResp,TotalCli,
					(   SELECT Cd,Tp,Autorzc,PorteCli,TpCtrl,LEFT(CONVERT(VARCHAR,IniRelactCli,120),10) AS IniRelactCli,FatAnual,CongEcon,ClassCli,
								(   SELECT  DetCli,IPOC,Contrt,Mod,Cosif,OrigemRec,Indx,PercIndx,VarCamb,CEP,TaxEft,LEFT(CONVERT(VARCHAR,DtContr,120),10) AS DtContr,VlrContr,NatuOp,LEFT(CONVERT(VARCHAR,DtVencOp,120),10) AS DtVencOp,ClassOp,ProvConsttd,DiaAtraso,CaracEspecial,DtaProxParcela,VlrProxParcela,QtdParcelas,
											(SELECT v20,v40,v60,v80,v110,v120,v130,v140,v150,v160,v165,v170,v175,v180,v190,v199,v205,v210,v220,v230,v240,v245,v250,v255,v260,v270,v280,v290,v310,v320,v330 FROM TB_3040_XML_OP AS Venc WHERE Venc.ID_XML_OP = OP.ID_XML_OP AND Venc.IS_BAIXA = 0 FOR XML AUTO, TYPE),
											(SELECT Tp,Cd,Ident,Valor,CONVERT(NUMERIC(19,5),Perc) as Perc,Qtd FROM TB_3040_XML_INF AS Inf WHERE Inf.ID_XML_OP = Op.ID_XML_OP FOR XML AUTO, TYPE),
											(SELECT Tp,Ident,PercGar,VlrOrig,VlrData,LEFT(CONVERT(VARCHAR,DtReav,120),10) AS DtReav FROM TB_3040_XML_GAR AS Gar WHERE Gar.ID_XML_OP = Op.ID_XML_OP FOR XML AUTO, TYPE)
									FROM    TB_3040_XML_OP AS Op WHERE Op.ID_XML_CLI = Cli.ID_XML_CLI FOR XML AUTO, TYPE)
						FROM    TB_3040_XML_CLI AS Cli WHERE Cli.ID_XML = Doc3040.ID_XML FOR XML AUTO, TYPE
					),
					(SELECT NatuOp,Mod,OrigemRec,VincME,ClassOp,FaixaVlr,PrzProvm,Localiz,TpCli,TpCtrl,DesempOp,CaracEspecial,ProvConsttd,QtdOp,QtdCli,
							(SELECT v20,v40,v60,v80,v110,v120,v130,v140,v150,v160,v165,v170,v175,v180,v190,v199,v205,v210,v220,v230,v240,v245,v250,v255,v260,v270,v280,v290,v310,v320,v330 FROM TB_3040_XML_AGREG AS Venc WHERE Venc.ID_XML_AGREG = Agreg.ID_XML_AGREG FOR XML AUTO, TYPE)
					 FROM TB_3040_XML_AGREG AS Agreg WHERE Agreg.ID_XML = Doc3040.ID_XML FOR XML AUTO, TYPE)
			FROM TB_3040_XML AS Doc3040 WHERE Doc3040.ID_XML = @id_xml FOR XML AUTO, TYPE)

    UPDATE TB_3040_XML SET DOC3040 = @XML WHERE ID_XML = @id_xml

    DELETE FROM TB_3040_XML_GAR
    DELETE FROM TB_3040_XML_INF
    DELETE FROM TB_3040_XML_OP
    DELETE FROM TB_3040_XML_CLI
    DELETE FROM TB_3040_XML_AGREG
END