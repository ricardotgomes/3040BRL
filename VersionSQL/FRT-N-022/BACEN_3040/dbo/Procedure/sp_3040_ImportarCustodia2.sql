/****** Object:  Procedure [dbo].[sp_3040_ImportarCustodia2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE 

 PROCEDURE [dbo].[sp_3040_ImportarCustodia2]
    @p_idFundo INT, 
    @p_dtPosicao DATETIME,
    @user VARCHAR(50), 
    @cdError INT OUTPUT, 
    @dsError VARCHAR(500) OUTPUT,
    @debug INT = 0
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @idFundo INT = @p_idFundo, 
			@dtPosicao DATETIME = @p_dtPosicao

    DECLARE @inicio DATETIME,
            @qtImpOp INT, 
            @dtImpOp DATETIME,
            @qtImpCli INT, 
            @dtImpCli DATETIME
    
    SET @inicio = GETDATE()
    SET @qtImpOp = 0
    SET @qtImpCli = 0
    

    DECLARE		@cnpjFundo VARCHAR(14), 
				@nomeFundo VARCHAR(100), 
				@TpFundo VARCHAR(MAX),
				@data DATETIME;

   -- Dados nacessários para execução
    SELECT 
                @nomeFundo = NM_FUNDO,
                @data = GETDATE(), 
                @cnpjFundo = CD_CNPJ_FUNDO,
				@TpFundo = TP_FUNDO
    FROM        TB_3040_BAS_FUNDO WHERE ID_FUNDO = @idFundo

    IF (@nomeFundo IS NULL) 
    BEGIN
    
        IF (@debug = 1)
        BEGIN
            PRINT 'Fundo informado não existe'
        END

        SET @cdError = 1
        SET @dsError = 'Fundo informado não existe'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM TB_3040_DP_PADRAO WHERE ID_FUNDO = @idFundo) 
    BEGIN
    
        IF (@debug = 1)
        BEGIN
            PRINT 'Não foi encontrado De/Para Padrão para o fundo ' + @nomeFundo
        END

        SET @cdError = 2
            SET @dsError = 'Não foi encontrado De/Para Padrão para o fundo ' + @nomeFundo
        RETURN
    END
    
    IF (@debug = 1)
    BEGIN
        PRINT 'Importando fundo ' + @nomeFundo
    END

	IF(@TpFundo IN('NORMAL','HIBRIDO')) --SE FOR PADRONIZADO OU HIBRIDO
	BEGIN 
			--Importa posição do custódia PARA FUNDOS PADRONIZADOS
			INSERT INTO    TB_3040_IMP_OPERACAO (
						CNPJ_FUNDO,
						DT_POSICAO,
						CD_CONTRATO_CEDENTE,
						CD_CONTRATO_SACADO,
						DOC_ORIGINADOR,
						ID_SISTEMA_ORIGEM,
						CD_SISTEMA_ORIGEM,
						TP_ATIVO,
						DS_CONTA_COSIF,
						FL_COOBRIGACAO,
						DT_AQUISICAO,
						DT_VENCIMENTO,
						TX_OPERACAO,
						VL_AQUISICAO,
						VL_NOMINAL,
						VL_PERC_COOBRIGACAO,
						VL_PERC_SUBORDINACAO,
						VL_PDD,
						VL_PERC_INDEXADOR,
						DOC_CEDENTE,
						DOC_SACADO,
						CD_NATUREZA,
						CD_MODALIDADE,
						CD_ORIG_RECURSOS,
						CD_INDEXADOR,
						CD_VAR_CAMB,
						CD_CARAC_ESPEC,
						CD_RATING,
						CD_VINC_ME,
						CD_PRAZO_PROV,
						CD_DESEMPENHO
						)
			SELECT
						CONVERT(VARCHAR(14), f.NU_CNPJ)					AS    CNPJ_FUNDO,
						CONVERT(DATE, e.DT)								AS    DT_POSICAO,
						--CONVERT(VARCHAR(100), COALESCE(CONVERT(VARCHAR, r.ID_OPERACAO), r.DS_SEU_NUMERO))
						--												AS    CD_CONTRATO_CEDENTE, --TODO: não é cessão. Usar o campo novo ID_OPERACAO quando estiver confiável == teste helder operações duplicando xml quando traz o id_operacao
						CONVERT(VARCHAR(100), r.DS_SEU_NUMERO)			AS    CD_CONTRATO_CEDENTE, 
					   -- CASE WHEN CONVERT(VARCHAR(100), r.DS_NU_DOCUMENTO) = '0000000000' THEN R.ID_RECEBIVEL ELSE CONVERT(VARCHAR(100), r.DS_NU_DOCUMENTO) END    AS    CD_CONTRATO_SACADO, ---QUANDO VALOR 0000000 CRITICA NO VALIDADOR COMO DUPLICADO
						  CONVERT(VARCHAR(100), r.DS_SEU_NUMERO)        AS    CD_CONTRATO_SACADO, ---
						--CONVERT(VARCHAR(100), r.DS_NU_DOCUMENTO)      AS    CD_CONTRATO_SACADO, ---TROCADO PELA LINHA DE CIMA
						CONVERT(VARCHAR(14), o.NU_CPF_CNPJ)				AS    DOC_ORIGINADOR,
						CONVERT(VARCHAR(100), r.DS_SEU_NUMERO)			AS    ID_SISTEMA_ORIGEM,
						'FRT'											AS    CD_SISTEMA_ORIGEM,
						CONVERT(VARCHAR(40), t.NM_TIPO_RECEBIVEL)		AS    TP_ATIVO,
						CONVERT(VARCHAR(100), NULL)						AS    DS_CONTA_COSIF,
						CONVERT(BIT, r.IC_COOBRIGACAO)					AS    FL_COOBRIGACAO,
						CONVERT(DATE, r.DT_AQUISICAO)					AS    DT_AQUISICAO, -- ALTERADO PARA RIO TIBAGI CONVERT(DATE, r.DT_AQUISICAO)                AS    DT_AQUISICAO, HELDER 14-07
						--CASE WHEN DATEDIFF(dd, @dtPosicao, r.DT_VENCIMENTO) < 540 THEN r.DT_VENCIMENTO  ELSE r.DT_AQUISICAO END AS    DT_AQUISICAO,
						CONVERT(DATE, r.DT_VENCIMENTO)					AS    DT_VENCIMENTO,
						CONVERT(NUMERIC(25,10), ROUND(r.TX_CESSAO, 10))
																		AS    TX_OPERACAO,
						--CASE WHEN R.VL_AQUISICAO = 0 THEN 0.01 ELSE CONVERT(NUMERIC(19,4), ROUND(R.VL_AQUISICAO,4)) END AS VL_AQUISICAO, --HELDER     
						CONVERT(NUMERIC(19,4), ROUND(r.VL_AQUISICAO,4)) AS    VL_AQUISICAO,                                            
						--CASE WHEN R.VL_NOMINAL = 0 THEN 0.01 ELSE CONVERT(NUMERIC(19,4), ROUND(r.VL_NOMINAL,4)) END AS VL_NOMINAL, --HELDER 
						--CONVERT(NUMERIC(19,4), ROUND(r.VL_NOMINAL,4)) AS    VL_NOMINAL, 
						CONVERT(NUMERIC(19,4), ROUND(E.VL_PRESENTE,4))	AS    VL_PRESENTE,  
						CONVERT(NUMERIC(10,7), ROUND(NULL,7))			AS    VL_PERC_COOBRIGACAO,
						CONVERT(NUMERIC(10,7), ROUND(NULL,7))			AS    VL_PERC_SUBORDINACAO,
						CONVERT(NUMERIC(19,4), ROUND(e.VL_PDD,4))		AS    VL_PDD,
						CONVERT(NUMERIC(3,2), ROUND(NULL,2))			AS    VL_PERC_INDEXADOR,
						CONVERT(VARCHAR(14), c.NU_CPF_CNPJ)				AS    DOC_CEDENTE,
						CONVERT(VARCHAR(14), s.NU_CPF_CNPJ)				AS    DOC_SACADO,
						--CONVERT(VARCHAR(2),  D.NATUREZA)              AS    CD_NATUREZA, -- ANEXO 02      --rubem incluiu 09052017
						CONVERT(VARCHAR(2), NULL)						AS    CD_NATUREZA, -- ANEXO 02   
						CONVERT(VARCHAR(4), NULL)						AS    CD_MODALIDADE, -- ANEXO 03
						CONVERT(VARCHAR(4), NULL)						AS    CD_ORIG_RECURSOS, -- ANEXO 04
						CONVERT(VARCHAR(2), NULL)						AS    CD_INDEXADOR, -- ANEXO 05
						CONVERT(VARCHAR(3), NULL)						AS    CD_VAR_CAMB, -- ANEXO 06
						CONVERT(VARCHAR(2), NULL)						AS    CD_CARAC_ESPEC, -- ANEXO 08
						CONVERT(VARCHAR(2), fp.DS_RISCO_ATRASO)		    AS    CD_RATING, -- ANEXO 17 - RATING DO PDD DO CUSTÓDIA --- 
						--CONVERT(VARCHAR(2), NULL)						AS    CD_RATING, -- ANEXO 17
						CONVERT(VARCHAR(1), NULL)						AS    CD_VINC_ME, -- ANEXO 18
						CONVERT(VARCHAR(1), NULL)						AS    CD_PRAZO_PROV, -- ANEXO 19
						CONVERT(VARCHAR(2), NULL)						AS    CD_DESEMPENHO -- ANEXO 28
			FROM          FIDC_CUSTODIA.dbo.TB_ESTOQUE                  AS    e    WITH (NOLOCK)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO                    AS    f    WITH (NOLOCK) ON  (e.ID_FUNDO            =    f.ID_FUNDO)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_RECEBIVEL                AS    r    WITH (NOLOCK) ON  (r.ID_RECEBIVEL        =    e.ID_RECEBIVEL)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_TIPO_RECEBIVEL           AS    t    WITH (NOLOCK) ON  (t.ID_TIPO_RECEBIVEL   =    r.ID_TIPO_RECEBIVEL)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO_CEDENTE            AS    c    WITH (NOLOCK) ON  (r.ID_CEDENTE          =    c.ID_CEDENTE)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO_SACADO             AS    s    WITH (NOLOCK) ON  (r.ID_SACADO           =    s.ID_SACADO)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_PESSOA                   AS    o    WITH (NOLOCK) ON  (r.ID_ORIGINADOR       =    o.ID_PESSOA)
			INNER JOIN	  FIDC_CUSTODIA.dbo.TB_FAIXA_PDD				 AS    fp   WITH (NOLOCK) ON  (e.ID_FAIXA_PDD		 =    fp.ID_FAIXA_PDD)
			WHERE          e.DT        =    @dtPosicao
			AND            f.NU_CNPJ   =    @cnpjFundo
			AND			   R.VL_AQUISICAO <> 0 -- TESTE DIOGO
			AND			   R.VL_NOMINAL <> 0   -- TESTE DIOGO


			SET @qtImpOp = @@ROWCOUNT
			SET @dtImpOp = GETDATE()

			IF (@debug = 1)
			BEGIN
				PRINT 'Total de operações: ' + CONVERT(varchar, @qtImpOp)
			END


			--Importa os cedentes do custódia
			INSERT INTO    TB_3040_IMP_CLIENTE(
						TP_CLIENTE,
						CEP,
						CONG_ECONOMICO,    
						VL_FAT_ANUAL,    
						DT_INI_RELAC,    
						CD_LOCALIZACAO,    
						CD_TP_CONTROLE,    
						CD_TP_PESSOA,
						CD_RATING,    
						CD_AUTORIZACAO,    
						CD_PORTE_PJ,    
						CD_PORTE_PF,
						DOC_CLIENTE,
						NM_CLIENTE,
						IS_SFN
						)
			SELECT        DISTINCT
						'CEDENTE'										AS    TP_CLIENTE,
						CONVERT(VARCHAR(8), NULLIF(c.NU_CEP, ''))		AS    CEP,
						CONVERT(VARCHAR(40), NULLIF(c.NM_CONG_ECON, ''))
																		AS    CONG_ECONOMICO,
						CONVERT(NUMERIC(19,4), ROUND(NULLIF(c.VL_FAT_ANUAL, 0.0),4))
																		AS    VL_FAT_ANUAL,
						CONVERT(DATE, c.DT_INI_RELACIONAMENTO)			AS    DT_INI_RELAC,
						CONVERT(VARCHAR(2), NULLIF(c.DS_ESTADO,''))		AS    CD_LOCALIZACAO,	-- ANEXO 07
						CONVERT(VARCHAR(2), NULL)						AS    CD_TP_CONTROLE,	-- ANEXO 10
						CONVERT(VARCHAR(1), CASE WHEN c.IC_TIPO_PESSOA = 0 THEN '1' 
												 WHEN c.IC_TIPO_PESSOA = 1 THEN '2'
												 ELSE NULL
											END)						AS    CD_TP_PESSOA,		-- ANEXO 11
						CONVERT(VARCHAR(2), cl.CD_CLASS_RISCO)			AS    CD_RATING,		-- ANEXO 16
						CONVERT(VARCHAR(1), c.IC_AUTORIZACAO)			AS    CD_AUTORIZACAO,	-- ANEXO 20
						CONVERT(VARCHAR(1), CASE WHEN c.IC_TIPO_PESSOA = 1 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PJ,		-- ANEXO 24
						CONVERT(VARCHAR(1), CASE WHEN c.IC_TIPO_PESSOA = 0 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PF,		-- ANEXO 25
						CONVERT(VARCHAR(14), c.NU_CPF_CNPJ)				AS    DOC_CLIENTE,
						CONVERT(VARCHAR(100), c.NM_CEDENTE)				AS    NM_CLIENTE,
						CASE WHEN c.ID_TIPO_SOCIEDADE = 14 THEN 1 ELSE 0 END
																		AS    IS_SFN
			FROM        FIDC_CUSTODIA.dbo.TB_ESTOQUE               AS    e    WITH (NOLOCK)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO               AS    f    WITH (NOLOCK) ON    (e.ID_FUNDO         =    f.ID_FUNDO)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_RECEBIVEL           AS    r    WITH (NOLOCK) ON    (r.ID_RECEBIVEL     =    e.ID_RECEBIVEL)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO_CEDENTE       AS    c    WITH (NOLOCK) ON    (r.ID_CEDENTE       =    c.ID_CEDENTE 
																										AND   C.ID_FUNDO  =    F.ID_FUNDO) -- ADICIONAMOS PARA NÃO DAR DUPLICIDADE NA IMPORTACAO 11-08 HELDER 
			INNER JOIN  FIDC_CUSTODIA.dbo.TB_PORTE                 AS    p    WITH (NOLOCK) ON    (p.ID_PORTE         =    c.ID_PORTE)
			LEFT JOIN   FIDC_CUSTODIA.dbo.TB_CLASS_RISCO           AS    cl   WITH (NOLOCK) ON    (cl.ID_CLASS_RISCO  =    c.ID_CLASS_RISCO)
			WHERE        e.DT        =    @dtPosicao
			AND            f.NU_CNPJ    =    @cnpjFundo

			SET @qtImpCli = @qtImpCli + @@ROWCOUNT

			--Importa os sacados do custódia
			INSERT INTO    TB_3040_IMP_CLIENTE(
						TP_CLIENTE,
						CEP,
						CONG_ECONOMICO,    
						VL_FAT_ANUAL,    
						DT_INI_RELAC,    
						CD_LOCALIZACAO,    
						CD_TP_CONTROLE,    
						CD_TP_PESSOA,
						CD_RATING,    
						CD_AUTORIZACAO,    
						CD_PORTE_PJ,    
						CD_PORTE_PF,
						DOC_CLIENTE,
						NM_CLIENTE,
						IS_SFN
						)
			SELECT        DISTINCT
						'SACADO'										AS    TP_CLIENTE,
						CONVERT(VARCHAR(8), NULLIF(s.NU_CEP, ''))		AS    CEP,
						CONVERT(VARCHAR(40), NULLIF(s.NM_CONG_ECON, ''))
																		AS    CONG_ECONOMICO,
						CONVERT(NUMERIC(19,4), ROUND(NULLIF(s.VL_FAT_ANUAL, 0.0),4))
																		AS    VL_FAT_ANUAL,
						CONVERT(DATE, s.DT_INI_RELACIONAMENTO)			AS    DT_INI_RELAC,
						CONVERT(VARCHAR(2), NULLIF(s.DS_ESTADO,''))		AS    CD_LOCALIZACAO,	-- ANEXO 07
						CONVERT(VARCHAR(2), NULL)						AS    CD_TP_CONTROLE,	-- ANEXO 10
						CONVERT(VARCHAR(1), CASE WHEN s.IC_TIPO_PESSOA = 0 THEN '1' 
												 WHEN s.IC_TIPO_PESSOA = 1 THEN '2'
												 ELSE NULL
											END)						AS    CD_TP_PESSOA,		-- ANEXO 11
						CONVERT(VARCHAR(2), cl.CD_CLASS_RISCO)			AS    CD_RATING,		-- ANEXO 16
						CONVERT(VARCHAR(1), s.IC_AUTORIZACAO)			AS    CD_AUTORIZACAO,	-- ANEXO 20
						CONVERT(VARCHAR(1), CASE WHEN s.IC_TIPO_PESSOA = 1 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PJ,		-- ANEXO 24
						CONVERT(VARCHAR(1), CASE WHEN s.IC_TIPO_PESSOA = 0 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PF,		-- ANEXO 25
						CONVERT(VARCHAR(14), s.NU_CPF_CNPJ)				AS    DOC_CLIENTE,
						CONVERT(VARCHAR(100), s.NM_SACADO)				AS    NM_CLIENTE,
						CASE WHEN s.ID_TIPO_SOCIEDADE = 14 THEN 1 ELSE 0 END
																		AS    IS_SFN
			FROM        FIDC_CUSTODIA.dbo.TB_ESTOQUE               AS  e    WITH (NOLOCK)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO               AS  f    WITH (NOLOCK)ON    (e.ID_FUNDO                =    f.ID_FUNDO)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_RECEBIVEL           AS  r    WITH (NOLOCK)ON    (r.ID_RECEBIVEL            =    e.ID_RECEBIVEL)
			INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO_SACADO        AS  s    WITH (NOLOCK)ON    (r.ID_SACADO            =    s.ID_SACADO 
																										AND   S.ID_FUNDO   =    F.ID_FUNDO)-- ADICIONAMOS PARA NÃO DAR DUPLICIDADE NA IMPORTACAO 11-08 HELDER 
			INNER JOIN  FIDC_CUSTODIA.dbo.TB_PORTE                 AS  p    WITH (NOLOCK)ON    (p.ID_PORTE                =    s.ID_PORTE)
			LEFT JOIN  FIDC_CUSTODIA.dbo.TB_CLASS_RISCO            AS  cl   WITH (NOLOCK)ON    (cl.ID_CLASS_RISCO        =    s.ID_CLASS_RISCO)
			WHERE       e.DT        =    @dtPosicao
			AND         f.NU_CNPJ   =    @cnpjFundo
    
			SET @qtImpCli = @qtImpCli + @@ROWCOUNT
			SET @dtImpCli = GETDATE()

			IF (@debug = 1)
			BEGIN
				PRINT 'Total de clientes: ' + CONVERT(varchar, @qtImpCli)
			END

	END
	ELSE --PARA FUNDOS NÃO PADRONIZADOS
	BEGIN

		   --Importa posição do custódia PARA FUNDOS NÃO PADRONIZADOS
			INSERT INTO    TB_3040_IMP_OPERACAO (
						CNPJ_FUNDO,
						DT_POSICAO,
						CD_CONTRATO_CEDENTE,
						CD_CONTRATO_SACADO,
						DOC_ORIGINADOR,
						ID_SISTEMA_ORIGEM,
						CD_SISTEMA_ORIGEM,
						TP_ATIVO,
						DS_CONTA_COSIF,
						FL_COOBRIGACAO,
						DT_AQUISICAO,
						DT_VENCIMENTO,
						TX_OPERACAO,
						VL_AQUISICAO,
						VL_NOMINAL,
						VL_PERC_COOBRIGACAO,
						VL_PERC_SUBORDINACAO,
						VL_PDD,
						VL_PERC_INDEXADOR,
						DOC_CEDENTE,
						DOC_SACADO,
						CD_NATUREZA,
						CD_MODALIDADE,
						CD_ORIG_RECURSOS,
						CD_INDEXADOR,
						CD_VAR_CAMB,
						CD_CARAC_ESPEC,
						CD_RATING,
						CD_VINC_ME,
						CD_PRAZO_PROV,
						CD_DESEMPENHO
						)
		SELECT  CONVERT(VARCHAR(14), f.NU_CNPJ)							AS    CNPJ_FUNDO,
				CONVERT(DATE, MAX(e.DT))								AS    DT_POSICAO,
				CONVERT(VARCHAR(100), MAX(r.DS_SEU_NUMERO))				AS    CD_CONTRATO_CEDENTE, 
				CONVERT(VARCHAR(100), MAX(r.DS_SEU_NUMERO))				AS    CD_CONTRATO_SACADO, 
				CONVERT(VARCHAR(14),  MAX(o.NU_CPF_CNPJ))				AS    DOC_ORIGINADOR,
				CONVERT(VARCHAR(100), MAX(r.DS_SEU_NUMERO))				AS    ID_SISTEMA_ORIGEM,
				'FRT'													AS    CD_SISTEMA_ORIGEM,
				CONVERT(VARCHAR(40),(SELECT TOP 1 T.NM_TIPO_RECEBIVEL FROM FIDC_CUSTODIA.dbo.TB_TIPO_RECEBIVEL AS T))   
																		AS    TP_ATIVO,
				CONVERT(VARCHAR(100), NULL)								AS    DS_CONTA_COSIF,
				--CONVERT(BIT, CASE WHEN r.IC_COOBRIGACAO = 0 OR IC_COOBRIGACAO IS NULL THEN 1 ELSE 0 END )   AS    FL_COOBRIGACAO,
				 --1							                            AS    FL_COOBRIGACAO,
				CONVERT(BIT, r.IC_COOBRIGACAO)						    AS    FL_COOBRIGACAO,
				CONVERT(DATE, MAX(r.DT_AQUISICAO))						AS    DT_AQUISICAO, 
		   	  --CONVERT(DATE, MAX(r.DT_VENCIMENTO))						AS    DT_VENCIMENTO,
			   CONVERT(DATE, MAX(E.DT) + '19050624')					AS    DT_VENCIMENTO,
			  --CASE WHEN  r.DT_VENCIMENTO > e.DT THEN CONVERT(DATE,r.DT_VENCIMENTO) 
			  --ELSE CONVERT(DATE, E.DT + '19050624') END
			  --AS    DT_VENCIMENTO,
				CONVERT(NUMERIC(25,10), MAX(ROUND(r.TX_CESSAO, 10)))    AS    TX_OPERACAO,	
				SUM (r.VL_AQUISICAO)									AS    VL_AQUISICAO,                                           
				CONVERT(NUMERIC(19,4), ROUND(SUM(E.VL_PRESENTE),4))		AS    VL_NOMINAL,
				'100'													AS    VL_PERC_COOBRIGACAO,	
	        	--CONVERT(NUMERIC(10,7), ROUND(NULL,7))					AS    VL_PERC_COOBRIGACAO,
				CONVERT(NUMERIC(10,7), ROUND(NULL,7))					AS    VL_PERC_SUBORDINACAO,
				CONVERT(NUMERIC(19,4), ROUND(SUM(e.VL_PDD),4))			AS    VL_PDD,
				CONVERT(NUMERIC(3,2), ROUND(NULL,2))					AS    VL_PERC_INDEXADOR,
				CONVERT(VARCHAR(14), MAX(C.NU_CPF_CNPJ))				AS    DOC_CEDENTE,
				CONVERT(VARCHAR(14), MAX(S.NU_CPF_CNPJ))	            AS    DOC_SACADO,
				CONVERT(VARCHAR(2), NULL)								AS    CD_NATUREZA, -- ANEXO 02   
				CONVERT(VARCHAR(4), NULL)								AS    CD_MODALIDADE, -- ANEXO 03
				CONVERT(VARCHAR(4), NULL)								AS    CD_ORIG_RECURSOS, -- ANEXO 04
				CONVERT(VARCHAR(2), NULL)								AS    CD_INDEXADOR, -- ANEXO 05
				CONVERT(VARCHAR(3), NULL)								AS    CD_VAR_CAMB, -- ANEXO 06
				CONVERT(VARCHAR(2), NULL)								AS    CD_CARAC_ESPEC, -- ANEXO 08
				CONVERT(VARCHAR(2), NULL)								AS    CD_RATING, -- ANEXO 17
				CONVERT(VARCHAR(1), NULL)								AS    CD_VINC_ME, -- ANEXO 18
				CONVERT(VARCHAR(1), NULL)								AS    CD_PRAZO_PROV, -- ANEXO 19
				CONVERT(VARCHAR(2), NULL)								AS    CD_DESEMPENHO -- ANEXO 28
		FROM          FIDC_CUSTODIA.dbo.TB_ESTOQUE            AS    e    WITH (NOLOCK)
		INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO              AS    f    WITH (NOLOCK) ON  (e.ID_FUNDO             =    f.ID_FUNDO)
		INNER JOIN    FIDC_CUSTODIA.dbo.TB_RECEBIVEL          AS    r    WITH (NOLOCK) ON  (r.ID_RECEBIVEL         =    e.ID_RECEBIVEL)
		INNER JOIN    FIDC_CUSTODIA.dbo.TB_TIPO_RECEBIVEL     AS    t    WITH (NOLOCK) ON  (t.ID_TIPO_RECEBIVEL    =    r.ID_TIPO_RECEBIVEL)
		INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO_CEDENTE      AS    c    WITH (NOLOCK) ON  (r.ID_CEDENTE           =    c.ID_CEDENTE)
		INNER JOIN    FIDC_CUSTODIA.dbo.TB_FUNDO_SACADO       AS    s    WITH (NOLOCK) ON  (r.ID_SACADO            =    s.ID_SACADO)
		INNER JOIN    FIDC_CUSTODIA.dbo.TB_PESSOA             AS    o    WITH (NOLOCK) ON  (r.ID_ORIGINADOR        =    o.ID_PESSOA)
		INNER JOIN	  FIDC_CUSTODIA.dbo.TB_FAIXA_PDD	       AS    fp   WITH (NOLOCK) ON  (e.ID_FAIXA_PDD = fp.ID_FAIXA_PDD)
		WHERE          e.DT        =    @dtPosicao
		AND            f.NU_CNPJ   =    @cnpjFundo
		AND			   R.VL_AQUISICAO <> 0 -- TESTE DIOGO
		AND			   R.VL_NOMINAL <> 0   -- TESTE DIOGO
		GROUP BY f.NU_CNPJ,
	             r.ID_ARQUIVO,
				 r.IC_COOBRIGACAO,
				 e.DT
				 --,(CASE WHEN  r.DT_VENCIMENTO > e.DT THEN CONVERT(DATE,r.DT_VENCIMENTO) 
					--							  ELSE CONVERT(DATE, E.DT + '19050624') END)
	

		SET @qtImpOp = @@ROWCOUNT
		SET @dtImpOp = GETDATE()

		IF (@debug = 1)
		BEGIN
			PRINT 'Total de operações: ' + CONVERT(varchar, @qtImpOp)
		END


		--Importa os cedentes do custódia NAO PADROINIZADOS
			INSERT INTO    TB_3040_IMP_CLIENTE(
						TP_CLIENTE,
						CEP,
						CONG_ECONOMICO,    
						VL_FAT_ANUAL,    
						DT_INI_RELAC,    
						CD_LOCALIZACAO,    
						CD_TP_CONTROLE,    
						CD_TP_PESSOA,
						CD_RATING,    
						CD_AUTORIZACAO,    
						CD_PORTE_PJ,    
						CD_PORTE_PF,
						DOC_CLIENTE,
						NM_CLIENTE,
						IS_SFN
						)
			SELECT	CEDENTE.*
			FROM	(
			SELECT        DISTINCT
						'CEDENTE'										AS    TP_CLIENTE,
						CONVERT(VARCHAR(8), NULLIF(c.NU_CEP, ''))		AS    CEP,
						CONVERT(VARCHAR(40), NULLIF(c.NM_CONG_ECON, ''))
																		AS    CONG_ECONOMICO,
						CONVERT(NUMERIC(19,4), ROUND(NULLIF(c.VL_FAT_ANUAL, 0.0),4))
																		AS    VL_FAT_ANUAL,
						CONVERT(DATE, c.DT_INI_RELACIONAMENTO)			AS    DT_INI_RELAC,
						CONVERT(VARCHAR(2), NULLIF(c.DS_ESTADO,''))		AS    CD_LOCALIZACAO,	-- ANEXO 07
						CONVERT(VARCHAR(2), NULL)						AS    CD_TP_CONTROLE,	-- ANEXO 10
						CONVERT(VARCHAR(1), CASE WHEN c.IC_TIPO_PESSOA = 0 THEN '1' 
												 WHEN c.IC_TIPO_PESSOA = 1 THEN '2'
												 ELSE NULL
											END)						AS    CD_TP_PESSOA,		-- ANEXO 11
						CONVERT(VARCHAR(2), cl.CD_CLASS_RISCO)			AS    CD_RATING,		-- ANEXO 16
						CONVERT(VARCHAR(1), c.IC_AUTORIZACAO)			AS    CD_AUTORIZACAO,	-- ANEXO 20
						CONVERT(VARCHAR(1), CASE WHEN c.IC_TIPO_PESSOA = 1 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PJ,		-- ANEXO 24
						CONVERT(VARCHAR(1), CASE WHEN c.IC_TIPO_PESSOA = 0 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PF,		-- ANEXO 25
						CONVERT(VARCHAR(14), c.NU_CPF_CNPJ)				AS    DOC_CLIENTE,
						CONVERT(VARCHAR(100), c.NM_CEDENTE)				AS    NM_CLIENTE,
								CASE WHEN c.ID_TIPO_SOCIEDADE = 14 THEN 1 ELSE 0 END AS IS_SFN
				FROM			FIDC_CUSTODIA.dbo.TB_ESTOQUE          AS    e    WITH (NOLOCK)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_FUNDO            AS    f    WITH (NOLOCK) ON    (e.ID_FUNDO         =    f.ID_FUNDO)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_RECEBIVEL        AS    r    WITH (NOLOCK) ON    (r.ID_RECEBIVEL     =    e.ID_RECEBIVEL)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_FUNDO_CEDENTE    AS    c    WITH (NOLOCK) ON    (r.ID_CEDENTE       =    c.ID_CEDENTE  
																											   AND C.ID_FUNDO = F.ID_FUNDO)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_PORTE            AS    p    WITH (NOLOCK) ON    (p.ID_PORTE         =    c.ID_PORTE)
				LEFT JOIN		FIDC_CUSTODIA.dbo.TB_CLASS_RISCO      AS    cl   WITH (NOLOCK) ON    (cl.ID_CLASS_RISCO  =    c.ID_CLASS_RISCO)
			WHERE        e.DT        =    @dtPosicao
			AND          f.NU_CNPJ   =    @cnpjFundo
					) AS CEDENTE
			    INNER JOIN		TB_3040_IMP_OPERACAO AS IMP
			ON				IMP.DOC_CEDENTE = CEDENTE.DOC_CLIENTE

			SET @qtImpCli = @qtImpCli + @@ROWCOUNT


			--Importa os sacados do custódia NAO PADRONIZADOS
			INSERT INTO    TB_3040_IMP_CLIENTE(
						TP_CLIENTE,
						CEP,
						CONG_ECONOMICO,    
						VL_FAT_ANUAL,    
						DT_INI_RELAC,    
						CD_LOCALIZACAO,    
						CD_TP_CONTROLE,    
						CD_TP_PESSOA,
						CD_RATING,    
						CD_AUTORIZACAO,    
						CD_PORTE_PJ,    
						CD_PORTE_PF,
						DOC_CLIENTE,
						NM_CLIENTE,
						IS_SFN
						)
			SELECT	SACADO.*
			FROM	(
			SELECT        DISTINCT
						'SACADO'										AS    TP_CLIENTE,
						CONVERT(VARCHAR(8), NULLIF(s.NU_CEP, ''))		AS    CEP,
						CONVERT(VARCHAR(40), NULLIF(s.NM_CONG_ECON, ''))
																		AS    CONG_ECONOMICO,
						CONVERT(NUMERIC(19,4), ROUND(NULLIF(s.VL_FAT_ANUAL, 0.0),4))
																		AS    VL_FAT_ANUAL,
						CONVERT(DATE, s.DT_INI_RELACIONAMENTO)			AS    DT_INI_RELAC,
						CONVERT(VARCHAR(2), NULLIF(s.DS_ESTADO,''))		AS    CD_LOCALIZACAO,	-- ANEXO 07
						CONVERT(VARCHAR(2), NULL)						AS    CD_TP_CONTROLE,	-- ANEXO 10
						CONVERT(VARCHAR(1), CASE WHEN s.IC_TIPO_PESSOA = 0 THEN '1' 
												 WHEN s.IC_TIPO_PESSOA = 1 THEN '2'
												 ELSE NULL
											END)						AS    CD_TP_PESSOA,		-- ANEXO 11
						CONVERT(VARCHAR(2), cl.CD_CLASS_RISCO)			AS    CD_RATING,		-- ANEXO 16
						CONVERT(VARCHAR(1), s.IC_AUTORIZACAO)			AS    CD_AUTORIZACAO,	-- ANEXO 20
						CONVERT(VARCHAR(1), CASE WHEN s.IC_TIPO_PESSOA = 1 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PJ,		-- ANEXO 24
						CONVERT(VARCHAR(1), CASE WHEN s.IC_TIPO_PESSOA = 0 THEN p.CD_SUB_PORTE ELSE NULL END)
																		AS    CD_PORTE_PF,		-- ANEXO 25
						CONVERT(VARCHAR(14), s.NU_CPF_CNPJ)				AS    DOC_CLIENTE,
						CONVERT(VARCHAR(100), s.NM_SACADO)				AS    NM_CLIENTE,
								CASE WHEN s.ID_TIPO_SOCIEDADE = 14 THEN 1 ELSE 0 END AS    IS_SFN
				FROM			FIDC_CUSTODIA.dbo.TB_ESTOQUE        AS  e    WITH (NOLOCK)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_FUNDO          AS  f    WITH (NOLOCK)ON    (e.ID_FUNDO        =    f.ID_FUNDO)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_RECEBIVEL      AS  r    WITH (NOLOCK)ON    (r.ID_RECEBIVEL    =    e.ID_RECEBIVEL)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_FUNDO_SACADO   AS  s    WITH (NOLOCK)ON    (r.ID_SACADO       =    s.ID_SACADO  AND S.ID_FUNDO = F.ID_FUNDO)
				INNER JOIN		FIDC_CUSTODIA.dbo.TB_PORTE          AS  p    WITH (NOLOCK)ON    (p.ID_PORTE        =    s.ID_PORTE)
				LEFT JOIN		FIDC_CUSTODIA.dbo.TB_CLASS_RISCO    AS  cl   WITH (NOLOCK)ON    (cl.ID_CLASS_RISCO =    s.ID_CLASS_RISCO)
			WHERE        e.DT        =    @dtPosicao
			AND          f.NU_CNPJ   =    @cnpjFundo
		 	         ) AS SACADO
			    INNER JOIN	TB_3040_IMP_OPERACAO AS IMP
			     ON			IMP.DOC_SACADO = SACADO.DOC_CLIENTE
    
			SET @qtImpCli = @qtImpCli + @@ROWCOUNT
			SET @dtImpCli = GETDATE()

			IF (@debug = 1)
			BEGIN
				PRINT 'Total de clientes: ' + CONVERT(varchar, @qtImpCli)
			END
	END

    INSERT INTO TB_3040_IMP_LOG VALUES (
        @idFundo,
        @qtImpOp, 
        CONVERT(VARCHAR, @dtImpOp - @inicio, 14),
        @qtImpCli, 
        CONVERT(VARCHAR, @dtImpCli - @dtImpOp, 14),
        null, 
        null,
        null, 
        null,
        CONVERT(VARCHAR, GETDATE() - @inicio, 14)
        )
    
    SET @cdError = 0;
    SET @dsError = 'Importação executada com sucesso'
    RETURN @cdError
END 