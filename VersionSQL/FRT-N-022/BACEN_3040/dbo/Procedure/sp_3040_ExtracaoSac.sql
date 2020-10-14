/****** Object:  Procedure [dbo].[sp_3040_ExtracaoSac]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_3040_ExtracaoSac]
    @idFundo INT, 
    @dtPosicao DATETIME,
    @user VARCHAR(50), 
    @cdError INT OUTPUT, 
    @dsError VARCHAR(500) OUTPUT,
    @debug INT = 0

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @inicio DATETIME,
            @qtImpOp INT, 
            @dtImpOp DATETIME,
            @qtImpCli INT, 
            @dtImpCli DATETIME,
			@NM_FUNDO	VARCHAR (500)
    
    SET @inicio = GETDATE()
    SET @qtImpOp = 0
    SET @qtImpCli = 0
    
    DECLARE @cnpjFundo VARCHAR(14), @nomeFundo VARCHAR(100), @data DATETIME;

    --Dados nacessários para execução
    SELECT 
                @nomeFundo = NM_FUNDO,
                @data = GETDATE(), 
                @cnpjFundo = CD_CNPJ_FUNDO,
				@NM_FUNDO = NM_FUNDO
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
	
	IF EXISTS (SELECT * FROM TB_FUNDOS_MAPS WHERE NU_CNPJ = @cnpjFundo)
	BEGIN 

		SET @cdError = 0;
		SET @dsError = 'Importação executada com sucesso'
		RETURN @cdError
	END

    IF NOT EXISTS (SELECT * FROM BRLSAC.dbo.CLI_BAS WHERE CGC    = @cnpjFundo) 
    BEGIN
    
        IF (@debug = 1)
        BEGIN
            PRINT 'Não foi encontrado carteiras no SAC com o CNPJ ' + @cnpjFundo
        END

        SET @cdError = 2
        SET @dsError = 'Não foi encontrado carteiras no SAC com o CNPJ ' + @cnpjFundo
        RETURN
    END

	TRUNCATE TABLE TB_3040_IMP_OPERACAO
    TRUNCATE TABLE TB_3040_IMP_CLIENTE

	 IF @nomeFundo LIKE ('%IPANEMA%')
	 BEGIN
			IF (@debug = 1)
			BEGIN
				PRINT 'processando fundo ' + @cnpjFundo +  'TESTE'
			END

			DECLARE @TOT_REC	FLOAT
				,	@PDD		FLOAT

				set @PDD = 0

			SELECT     @TOT_REC = CONVERT(NUMERIC(19,4), ROUND(SUM(A.VL_FINANCEIRO), 4))
						
			FROM        BRLSAC..SAC_CL_PATRFI       AS	A
			INNER JOIN  BRLSAC..SAC_FI_CADASTRO     AS	C	WITH (NOLOCK) ON (A.FICAD_CD = C.CD)
			INNER JOIN  BRLSAC.DBO.CLI_BAS			AS	CL	WITH(NOLOCK) ON (A.CLCLI_CD = CL.CODCLI)
			WHERE	A.DT			=	@DTPOSICAO
				AND	CL.CGC			=	@CNPJFUNDO
				--AND TPFDO_CD			IN	('OUTROS','FIF')
				AND TPFDO_CD			IN	('OUTROS') -- RUBEM ALTEROU EM 26/02 A PEDIDO DA GISELE, RETIRAR FIF
				AND	C.SG_PRODUTO	=	'F'
				AND C.NO_CNPJ IS NOT NULL

				SELECT @PDD =  SUM(A.VL_FINANCEIRO) 
				FROM        BRLSAC..SAC_CL_PATRFI       AS	A
			INNER JOIN  BRLSAC..SAC_FI_CADASTRO     AS	C	WITH (NOLOCK) ON (A.FICAD_CD = C.CD)
			INNER JOIN  BRLSAC.DBO.CLI_BAS			AS	CL	WITH(NOLOCK) ON (A.CLCLI_CD = CL.CODCLI)
			WHERE	A.DT			=	@DTPOSICAO
				AND	CL.CGC			=	@CNPJFUNDO
				AND CD				IN ('1BRLREDI','1ACAOJUD','2ACAOJUD','3ACAOJUD','4ACAOJUD', 'AMORTIZA') 
				AND	C.SG_PRODUTO	<>	'F'
			if @PDD = 0 or @pdd is null
			begin
				select  @PDD = sum(vl)
				from BRLSAC.dbo.SAC_CL_CPR as a
				INNER JOIN  BRLSAC.DBO.CLI_BAS			AS	CL	WITH(NOLOCK) ON (A.CLCLI_CD = CL.CODCLI)
				where A.DT			=	@DTPOSICAO
				AND	CL.CGC			=	@CNPJFUNDO
				and MTTP_CD = '170'
				--and MTTP_CD IN ('170','808')
				
			end 		
			print convert(varchar, @pdd)

			 INSERT INTO    TB_3040_IMP_OPERACAO (
                CNPJ_FUNDO,
                DT_POSICAO,
                CD_CONTRATO_CEDENTE,
                CD_CONTRATO_SACADO,
                CD_LASTRO,
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
                CD_DESEMPENHO,
				IC_BAIXAR_ATIVO,
                IC_RECOMPRA
                )
		  	SELECT      CONVERT(VARCHAR(14), cl.CGC)                AS    CNPJ_FUNDO,
						CONVERT(DATE, a.DT)                         AS    DT_POSICAO,
						CONVERT(VARCHAR(100), RTRIM(LTRIM(a.FICAD_CD)))   AS    CD_CONTRATO_CEDENTE,
						CONVERT(VARCHAR(100), RTRIM(LTRIM(a.FICAD_CD)))		aS    CD_CONTRATO_SACADO,
						CONVERT(VARCHAR(100), RTRIM(LTRIM(a.FICAD_CD)))   AS    CD_LASTRO,
						CONVERT(VARCHAR(14), a.FICAD_CD)            AS    DOC_ORIGINADOR,
						CONVERT(VARCHAR(100), RTRIM(LTRIM(a.FICAD_CD)))   AS    ID_SISTEMA_ORIGEM,
						'SAC'                                       AS    CD_SISTEMA_ORIGEM,
						CONVERT(VARCHAR(40), a.FICAD_CD)             AS    TP_ATIVO,
						CONVERT(VARCHAR(100), NULL)                 AS    DS_CONTA_COSIF,
						CONVERT(BIT, NULL)                          AS    FL_COOBRIGACAO,
						CONVERT(DATE, c.DT_VIGENCIA)               AS    DT_AQUISICAO,
						--CONVERT(DATE, c.DT_VENCTO)               AS    DT_VENCIMENTO,	

					    CASE 					  WHEN c.DT_VENCTO IS NULL THEN '20301220'		ELSE C.DT_VENCTO  END            AS    DT_VENCIMENTO, --- ALTERADO PARA ATENDER FUNDO IPANEMA I 
						CONVERT(NUMERIC(25,10), 0)                  AS    TX_OPERACAO,
						--CONVERT(NUMERIC(19,4), ROUND(a.VL_FINANCEIRO_LIQ + (a.VL_FINANCEIRO_LIQ / @tot_rec) * @pdd, 4))
						COALESCE ( CONVERT(NUMERIC(19,4), ROUND(a.VL_FINANCEIRO + (a.VL_FINANCEIRO / CASE WHEN @tot_rec = 0 THEN 1 ELSE @tot_rec END) * @pdd, 4)),
						CONVERT(NUMERIC(19,4), ROUND(a.VL_FINANCEIRO, 2)))
																	AS    VL_AQUISICAO,

						CONVERT(NUMERIC(19,4), ROUND(a.VL_FINANCEIRO, 2))
																	AS    VL_NOMINAL,
						CONVERT(NUMERIC(10,7), ROUND(NULL, 7))      AS    VL_PERC_COOBRIGACAO,
						CONVERT(NUMERIC(10,7), ROUND(NULL, 7))      AS    VL_PERC_SUBORDINACAO,
						CONVERT(NUMERIC(19,4), ROUND(0, 4))         AS    VL_PDD,
						CONVERT(NUMERIC(5,2), 0)
																	AS    VL_PERC_INDEXADOR,
						CONVERT(VARCHAR(14), c.NO_CNPJ)				AS    DOC_CEDENTE,
						CONVERT(VARCHAR(14), c.NO_CNPJ)             AS    DOC_SACADO,
						CONVERT(VARCHAR(2), NULL)                   AS    CD_NATUREZA, -- ANEXO 02
						CONVERT(VARCHAR(4), NULL)                   AS    CD_MODALIDADE, -- ANEXO 03
						CONVERT(VARCHAR(4), NULL)                   AS    CD_ORIG_RECURSOS, -- ANEXO 04
						CONVERT(VARCHAR(25), NULL)
																	AS    CD_INDEXADOR, -- ANEXO 05
						CONVERT(VARCHAR(15), NULL)
																	AS    CD_VAR_CAMB, -- ANEXO 06
						CONVERT(VARCHAR(2), NULL)                   AS    CD_CARAC_ESPEC, -- ANEXO 08
						CONVERT(VARCHAR(2), NULL)                   AS    CD_RATING, -- ANEXO 17
						CONVERT(VARCHAR(1), NULL)                   AS    CD_VINC_ME, -- ANEXO 18
						CONVERT(VARCHAR(1), NULL)                   AS    CD_PRAZO_PROV, -- ANEXO 19
						CONVERT(VARCHAR(2), NULL)                   AS    CD_DESEMPENHO, -- ANEXO 28
						0 				                            AS IC_BAIXAR_ATIVO,
                        0                                           AS IC_RECOMPRA
				FROM        BRLSAC..SAC_CL_PATRFI       AS	a
				INNER JOIN  BRLSAC..SAC_FI_CADASTRO     AS	c	WITH (NOLOCK) ON (a.FICAD_CD = c.CD)
				INNER JOIN  BRLSAC.dbo.CLI_BAS			AS	cl	with(nolock) ON (a.CLCLI_CD = cl.CODCLI)
				WHERE	a.DT			=	@dtPosicao
					AND	cl.CGC			=	@cnpjFundo
					--AND TPFDO_CD		IN	('OUTROS','FIF')
					AND TPFDO_CD		IN	('OUTROS') -- RUBEM ALTEROU EM 26/02 A PEDIDO DA GISELE, RETIRAR FIF
					AND	c.SG_PRODUTO	=	'F'
					and c.NO_CNPJ is not null
					--AND CD				IN ('1BRLREDI','1ACAOJUD','2ACAOJUD','3ACAOJUD','4ACAOJUD', 'AMORTIZA') 

			SET @qtImpOp = @@ROWCOUNT
			SET @dtImpOp = GETDATE()

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
				SELECT      TP_CLIENTE,
                CEP,
                CONG_ECONOMICO,
                VL_FAT_ANUAL,
                MIN(DT_INI_RELAC) AS DT_INI_RELAC,
                CD_LOCALIZACAO,
                CD_TP_CONTROLE,
                CD_TP_PESSOA,
                CD_RATING,
                CD_AUTORIZACAO,
                CD_PORTE_PJ,
                CD_PORTE_PF,
                COALESCE(DOC_CLIENTE, '99999999999999'),
                CASE WHEN DOC_CLIENTE IS NULL OR NM_CLIENTE IS NULL THEN 'Não informado' ELSE NM_CLIENTE END,
                IS_SFN
    FROM        (	
	              SELECT  DISTINCT       'CEDENTE'					AS    TP_CLIENTE,
						CONVERT(VARCHAR(8), NULL)           AS    CEP,
						CONVERT(VARCHAR(40), NULL)                 AS    CONG_ECONOMICO,
						CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
						CONVERT(DATE, c.DT_VIGENCIA)                            AS    DT_INI_RELAC,
						CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
						CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
						CONVERT(VARCHAR(1), CASE WHEN LEN(c.NO_CNPJ) = 14 THEN '2'
													WHEN c.NO_CNPJ IS NULL THEN '2'
													ELSE '1' END)
																	 AS    CD_TP_PESSOA, -- ANEXO 11
						CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
						CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
						CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
						CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
						CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(c.NO_CNPJ)), ''))
																	AS    DOC_CLIENTE,
						CONVERT(VARCHAR(100), NULL)                 AS    NM_CLIENTE,
						CONVERT(BIT, NULL)                             AS    IS_SFN
					FROM        BRLSAC..SAC_CL_PATRFI       AS	a
					INNER JOIN  BRLSAC..SAC_FI_CADASTRO     AS	c	WITH (NOLOCK) ON (a.FICAD_CD = c.CD)
					INNER JOIN  BRLSAC.dbo.CLI_BAS			AS	cl	with(nolock) ON (a.CLCLI_CD = cl.CODCLI)
					WHERE	a.DT			=	@dtPosicao
						AND	cl.CGC			=	@cnpjFundo
						--AND TPFDO_CD		=	'OUTROS'
						AND	c.SG_PRODUTO	=	'F'
						and c.NO_CNPJ is not null    

				union all

				SELECT  DISTINCT       'SACADO'					AS    TP_CLIENTE,
						CONVERT(VARCHAR(8), NULL)           AS    CEP,
						CONVERT(VARCHAR(40), NULL)                 AS    CONG_ECONOMICO,
						CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
						CONVERT(DATE, c.DT_VIGENCIA)                            AS    DT_INI_RELAC,
						CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
						CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
						CONVERT(VARCHAR(1), CASE WHEN LEN(c.NO_CNPJ) = 14 THEN '2' -- TESTE 2
													WHEN c.NO_CNPJ IS NULL THEN '2' -- TESTE 2
													ELSE '1' END)
																	 AS    CD_TP_PESSOA, -- ANEXO 11
						CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
						CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
						CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
						CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
						CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(c.NO_CNPJ)), ''))
																	AS    DOC_CLIENTE,
						CONVERT(VARCHAR(100), NULL)                 AS    NM_CLIENTE,
						CONVERT(BIT, NULL)                             AS    IS_SFN
					FROM        BRLSAC..SAC_CL_PATRFI       AS	a
					INNER JOIN  BRLSAC..SAC_FI_CADASTRO     AS	c	WITH (NOLOCK) ON (a.FICAD_CD = c.CD)
					INNER JOIN  BRLSAC.dbo.CLI_BAS			AS	cl	with(nolock) ON (a.CLCLI_CD = cl.CODCLI)
					WHERE	a.DT			=	@dtPosicao
						AND	cl.CGC			=	@cnpjFundo
						--AND TPFDO_CD		=	'OUTROS'
						AND	c.SG_PRODUTO	=	'F' 
						and c.NO_CNPJ is not null     
				) as x
				GROUP BY    TP_CLIENTE,
                CEP,
                CONG_ECONOMICO,
                VL_FAT_ANUAL,
                CD_LOCALIZACAO,
                CD_TP_CONTROLE,
                CD_TP_PESSOA,
                CD_RATING,
                CD_AUTORIZACAO,
                CD_PORTE_PJ,
                CD_PORTE_PF,
                COALESCE(DOC_CLIENTE, '99999999999999'),
                CASE WHEN DOC_CLIENTE IS NULL OR NM_CLIENTE IS NULL THEN 'Não informado' ELSE NM_CLIENTE END,
                IS_SFN
			
    
			    SET @qtImpCli = @@ROWCOUNT
                SET @dtImpCli = GETDATE()

			    IF (@debug = 1)
			    BEGIN
			    	PRINT 'Total de operações: ' + CONVERT(varchar, @qtImpOp)
			    END
			    
			    IF (@debug = 1)
			    BEGIN
			    	PRINT 'Total de clientes: ' + CONVERT(varchar, @qtImpCli)
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
		--RETURN
	END
	ELSE

BEGIN
    --Importa posição do SAC
    INSERT INTO    TB_3040_IMP_OPERACAO (
                CNPJ_FUNDO,
                DT_POSICAO,
                CD_CONTRATO_CEDENTE,
                CD_CONTRATO_SACADO,
                CD_LASTRO,
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
                CD_DESEMPENHO,
				IC_BAIXAR_ATIVO,
                IC_RECOMPRA
                )
    SELECT        CNPJ_FUNDO,
                DT_POSICAO,
                CD_CONTRATO_CEDENTE,
                CD_CONTRATO_SACADO,
                CD_LASTRO,
                COALESCE(DOC_ORIGINADOR, '99999999999999'),
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
                COALESCE(DOC_CEDENTE, '99999999999999'),
                COALESCE(DOC_SACADO, '99999999999999'),
                CD_NATUREZA,
                CD_MODALIDADE,
                CD_ORIG_RECURSOS,
                CD_INDEXADOR,
                CD_VAR_CAMB,
                CD_CARAC_ESPEC,
                CD_RATING,
                CD_VINC_ME,
                CD_PRAZO_PROV,
                CD_DESEMPENHO,
				IC_BAIXAR_ATIVO,
                IC_RECOMPRA
    FROM        (
                SELECT      CONVERT(VARCHAR(14), cl.CGC)                AS    CNPJ_FUNDO,
                            CONVERT(DATE, a.DT)                         AS    DT_POSICAO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))   AS    CD_CONTRATO_CEDENTE,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))   AS    CD_CONTRATO_SACADO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(d.CD)))   AS    CD_LASTRO,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)            AS    DOC_ORIGINADOR,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))   AS    ID_SISTEMA_ORIGEM,
                            'SAC'                                       AS    CD_SISTEMA_ORIGEM,
                            CONVERT(VARCHAR(40), d.RFTP_CD)             AS    TP_ATIVO,
                            CONVERT(VARCHAR(100), NULL)                 AS    DS_CONTA_COSIF,
                            CONVERT(BIT, NULL)                          AS    FL_COOBRIGACAO,
                            CONVERT(DATE, p.DT_AQUISICAO)               AS    DT_AQUISICAO,
                            CONVERT(DATE, d.DT_VENCIMENTO)              AS    DT_VENCIMENTO,
                            CONVERT(NUMERIC(25,10), ROUND(p.VL_TIR / 100.0, 10))
                                                                        AS    TX_OPERACAO,
                            CONVERT(NUMERIC(19,4), ROUND(m.VL_PU_OPERACAO * m.QT, 4))
                                                                        AS    VL_AQUISICAO,
                            CONVERT(NUMERIC(19,4), ROUND(p.QT_DISPONIVEL * COALESCE(CASE WHEN p.VL_PU_MERCADO <> 0 THEN p.VL_PU_MERCADO ELSE NULL END, p.VL_PU), 2))
                                                                        AS    VL_NOMINAL,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))      AS    VL_PERC_COOBRIGACAO,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))      AS    VL_PERC_SUBORDINACAO,
                            CONVERT(NUMERIC(19,4), ROUND(0, 4))         AS    VL_PDD,
                            CONVERT(NUMERIC(5,2), ROUND(RTRIM(LTRIM(d.IDDIR_PC)), 2))
                                                                        AS    VL_PERC_INDEXADOR,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)            AS    DOC_CEDENTE,
                            CONVERT(VARCHAR(14), ci.NO_CGC)             AS    DOC_SACADO,
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_NATUREZA, -- ANEXO 02
                            CONVERT(VARCHAR(4), NULL)                   AS    CD_MODALIDADE, -- ANEXO 03
                            CONVERT(VARCHAR(4), NULL)                   AS    CD_ORIG_RECURSOS, -- ANEXO 04
                            CONVERT(VARCHAR(25), RTRIM(LTRIM(d.IDDIR_CD)))
                                                                        AS    CD_INDEXADOR, -- ANEXO 05
                            CONVERT(VARCHAR(15), RTRIM(LTRIM(d.BAMDA_CD)))
                                                                        AS    CD_VAR_CAMB, -- ANEXO 06
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_CARAC_ESPEC, -- ANEXO 08
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_RATING, -- ANEXO 17
                            CONVERT(VARCHAR(1), NULL)                   AS    CD_VINC_ME, -- ANEXO 18
                            CONVERT(VARCHAR(1), NULL)                   AS    CD_PRAZO_PROV, -- ANEXO 19
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_DESEMPENHO, -- ANEXO 28
							0                                           AS    IC_BAIXAR_ATIVO,
                            0                                           AS    IC_RECOMPRA
                FROM        BRLSAC.dbo.SAC_CL_PATRRF                   AS    a  with(nolock)
                INNER JOIN  BRLSAC.dbo.SAC_RF_POS                      AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN  BRLSAC.dbo.SAC_RF_OPERACAO                 AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_LASTRO                   AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_TIPO                     AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_MOV                      AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN  BRLSAC.dbo.CLI_BAS                         AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN  BRLSAC.dbo.BAS_CAD_IF                      AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                WHERE       a.DT                 =   @dtPosicao
                AND         cl.CGC               =   @cnpjFundo
                AND         p.QT_DISPONIVEL      <>  0
                AND         m.SG_OPERACAO        IN  ('C', 'T')
                AND         d.SG_MTM             <>  'N'
                AND         d.IC_ATIVO_PASSIVO   =   'A'
                AND         NOT EXISTS (SELECT TOP 1 1 FROM BRLSAC.dbo.SAC_RF_MEMORIA AS mm WHERE mm.RFOP_CD = a.RFOP_CD AND mm.DT = a.DT AND mm.SG_CURVA = 'M')
    
                UNION ALL

                SELECT      CONVERT(VARCHAR(14), cl.CGC)                AS    CNPJ_FUNDO,
                            CONVERT(DATE, a.DT)                         AS    DT_POSICAO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))   AS    CD_CONTRATO_CEDENTE,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))   AS    CD_CONTRATO_SACADO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(d.CD)))   AS    CD_LASTRO,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)            AS    DOC_ORIGINADOR,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))   AS    ID_SISTEMA_ORIGEM,
                            'SAC'                                       AS    CD_SISTEMA_ORIGEM,
                            CONVERT(VARCHAR(40), d.RFTP_CD)             AS    TP_ATIVO,
                            CONVERT(VARCHAR(100), NULL)                 AS    DS_CONTA_COSIF,
                            CONVERT(BIT, NULL)                          AS    FL_COOBRIGACAO,
                            CONVERT(DATE, p.DT_AQUISICAO)               AS    DT_AQUISICAO,
                            CONVERT(DATE, d.DT_VENCIMENTO)              AS    DT_VENCIMENTO,
                            CONVERT(NUMERIC(25,10), ROUND(p.VL_TIR / 100.0, 10))
                                                                        AS    TX_OPERACAO,
                            CONVERT(NUMERIC(19,4), ROUND(m.VL_PU_OPERACAO * m.QT, 4))
                                                                        AS    VL_AQUISICAO,
                            CONVERT(NUMERIC(19,4), ROUND(p.QT_DISPONIVEL * mm.VL_PMT / mm.VL_FATOR, 2))
                                                                        AS    VL_NOMINAL,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))      AS    VL_PERC_COOBRIGACAO,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))      AS    VL_PERC_SUBORDINACAO,
                            CONVERT(NUMERIC(19,4), ROUND(0, 4))         AS    VL_PDD,
                            CONVERT(NUMERIC(5,2), ROUND(RTRIM(LTRIM(d.IDDIR_PC)), 2))
                                                                        AS    VL_PERC_INDEXADOR,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)            AS    DOC_CEDENTE,
                            CONVERT(VARCHAR(14), ci.NO_CGC)             AS    DOC_SACADO,
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_NATUREZA, -- ANEXO 02
                            CONVERT(VARCHAR(4), NULL)                   AS    CD_MODALIDADE, -- ANEXO 03
                            CONVERT(VARCHAR(4), NULL)                   AS    CD_ORIG_RECURSOS, -- ANEXO 04
                            CONVERT(VARCHAR(25), RTRIM(LTRIM(d.IDDIR_CD)))
                                                                        AS    CD_INDEXADOR, -- ANEXO 05
                            CONVERT(VARCHAR(15), RTRIM(LTRIM(d.BAMDA_CD)))
                                                                        AS    CD_VAR_CAMB, -- ANEXO 06
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_CARAC_ESPEC, -- ANEXO 08
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_RATING, -- ANEXO 17
                            CONVERT(VARCHAR(1), NULL)                   AS    CD_VINC_ME, -- ANEXO 18
                            CONVERT(VARCHAR(1), NULL)                   AS    CD_PRAZO_PROV, -- ANEXO 19
                            CONVERT(VARCHAR(2), NULL)                   AS    CD_DESEMPENHO, -- ANEXO 28
							0                                           AS    IC_BAIXAR_ATIVO,
                            0                                           AS    IC_RECOMPRA
                FROM        BRLSAC.dbo.SAC_CL_PATRRF                   AS    a  with(nolock)
                INNER JOIN  BRLSAC.dbo.SAC_RF_POS                      AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN  BRLSAC.dbo.SAC_RF_OPERACAO                 AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_LASTRO                   AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_TIPO                     AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_MOV                      AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN  BRLSAC.dbo.CLI_BAS                         AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN  BRLSAC.dbo.BAS_CAD_IF                      AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN  BRLSAC.dbo.SAC_RF_MEMORIA                  AS    mm with(nolock) ON (a.RFOP_CD = mm.RFOP_CD AND mm.DT = a.DT)
                WHERE       a.DT                    =    @dtPosicao
                AND         cl.CGC                  =    @cnpjFundo
                AND         p.QT_DISPONIVEL         <>    0
                AND         m.SG_OPERACAO           IN    ('C', 'T')
                AND         d.SG_MTM                <>  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND         EXISTS (SELECT TOP 1 1 FROM BRLSAC.dbo.SAC_RF_MEMORIA AS mm WHERE mm.RFOP_CD = a.RFOP_CD AND mm.DT = a.DT AND mm.SG_CURVA = 'M')
                AND         mm.SG_CURVA             =    'M'
                
                UNION ALL

                SELECT        CONVERT(VARCHAR(14), cl.CGC)               AS    CNPJ_FUNDO,
                            CONVERT(DATE, a.DT)                          AS    DT_POSICAO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))    AS    CD_CONTRATO_CEDENTE,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))    AS    CD_CONTRATO_SACADO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(d.CD)))    AS    CD_LASTRO,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)             AS    DOC_ORIGINADOR,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))    AS    ID_SISTEMA_ORIGEM,
                            'SAC'                                        AS    CD_SISTEMA_ORIGEM,
                            CONVERT(VARCHAR(40), d.RFTP_CD)              AS    TP_ATIVO,
                            CONVERT(VARCHAR(100), NULL)                  AS    DS_CONTA_COSIF,
                            CONVERT(BIT, NULL)                           AS    FL_COOBRIGACAO,
                            CONVERT(DATE, p.DT_AQUISICAO)                AS    DT_AQUISICAO,
                            CONVERT(DATE, d.DT_VENCIMENTO)               AS    DT_VENCIMENTO,
                            CONVERT(NUMERIC(25,10), ROUND(p.VL_TIR / 100.0, 10))
                                                                         AS    TX_OPERACAO,
                            CONVERT(NUMERIC(19,4), ROUND(CASE WHEN mm.SG_EVENTO = 'I' THEN m.VL_PU_OPERACAO * m.QT * mm.PC/100 ELSE 0.0 END, 4))
                                                                         AS    VL_AQUISICAO,
                            CONVERT(NUMERIC(19,4), ROUND(p.QT_DISPONIVEL * mm.VL_PMT / mm.VL_FATOR, 2))
                                                                         AS    VL_NOMINAL,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))       AS    VL_PERC_COOBRIGACAO,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))       AS    VL_PERC_SUBORDINACAO,
                            CONVERT(NUMERIC(19,4), ROUND(0, 4))          AS    VL_PDD,
                            CONVERT(NUMERIC(5,2), ROUND(RTRIM(LTRIM(d.IDDIR_PC)), 2))
                                                                         AS    VL_PERC_INDEXADOR,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)             AS    DOC_CEDENTE,
                            CONVERT(VARCHAR(14), ci.NO_CGC)              AS    DOC_SACADO,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_NATUREZA, -- ANEXO 02
                            CONVERT(VARCHAR(4), NULL)                    AS    CD_MODALIDADE, -- ANEXO 03
                            CONVERT(VARCHAR(4), NULL)                    AS    CD_ORIG_RECURSOS, -- ANEXO 04
                            CONVERT(VARCHAR(25), RTRIM(LTRIM(d.IDDIR_CD)))
                                                                         AS    CD_INDEXADOR, -- ANEXO 05
                            CONVERT(VARCHAR(15), RTRIM(LTRIM(d.BAMDA_CD)))
                                                                         AS    CD_VAR_CAMB, -- ANEXO 06
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_CARAC_ESPEC, -- ANEXO 08
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 17
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_VINC_ME, -- ANEXO 18
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PRAZO_PROV, -- ANEXO 19
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_DESEMPENHO, -- ANEXO 28
							0                                           AS    IC_BAIXAR_ATIVO,
                            0                                           AS    IC_RECOMPRA
                FROM        BRLSAC.dbo.SAC_CL_PATRRF                    AS    a  with(nolock)
                INNER JOIN  BRLSAC.dbo.SAC_RF_POS                       AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN  BRLSAC.dbo.SAC_RF_OPERACAO                  AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_LASTRO                    AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_TIPO                      AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN  BRLSAC.dbo.SAC_RF_MOV                       AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN  BRLSAC.dbo.CLI_BAS                          AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN  BRLSAC.dbo.BAS_CAD_IF                       AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN  BRLSAC.dbo.SAC_RF_MEMORIA                   AS    mm with(nolock) ON (a.RFOP_CD = mm.RFOP_CD AND mm.DT = a.DT)
                WHERE       a.DT                    =    @dtPosicao
                AND         cl.CGC                  =    @cnpjFundo
                AND         p.QT_DISPONIVEL         <>   0
                AND         m.SG_OPERACAO           IN   ('C', 'T')
                AND         d.SG_MTM                =   'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
    
                UNION ALL

                SELECT        CONVERT(VARCHAR(14), cl.CGC)                AS    CNPJ_FUNDO,
                            CONVERT(DATE, mt.DT)                        AS    DT_POSICAO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))    AS    CD_CONTRATO_CEDENTE,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))    AS    CD_CONTRATO_SACADO,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(d.CD)))   AS  CD_LASTRO,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)            AS    DOC_ORIGINADOR,
                            CONVERT(VARCHAR(100), RTRIM(LTRIM(c.CD)))    AS    ID_SISTEMA_ORIGEM,
                            'SAC'                                        AS    CD_SISTEMA_ORIGEM,
                            CONVERT(VARCHAR(40), d.RFTP_CD)                AS    TP_ATIVO,
                            CONVERT(VARCHAR(100), NULL)                    AS    DS_CONTA_COSIF,
                            CONVERT(BIT, NULL)                            AS    FL_COOBRIGACAO,
                            CONVERT(DATE, m.DT)                            AS    DT_AQUISICAO,
                            CONVERT(DATE, d.DT_VENCIMENTO)                AS    DT_VENCIMENTO,
                            CONVERT(NUMERIC(25,10), ROUND(c.VL_JUROSOPER / 100.0, 10))
                                                                        AS    TX_OPERACAO,
                            CONVERT(NUMERIC(19,4), ROUND(m.VL_PU_OPERACAO * m.QT, 4))
                                                                        AS    VL_AQUISICAO,
                            CONVERT(NUMERIC(19,4), ROUND(mt.VL, 2))        AS    VL_NOMINAL,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))        AS    VL_PERC_COOBRIGACAO,
                            CONVERT(NUMERIC(10,7), ROUND(NULL, 7))        AS    VL_PERC_SUBORDINACAO,
                            CONVERT(NUMERIC(19,4), ROUND(0, 4))            AS    VL_PDD,
                            CONVERT(NUMERIC(5,2), ROUND(RTRIM(LTRIM(d.IDDIR_PC)), 2))
                                                                        AS    VL_PERC_INDEXADOR,
                            CONVERT(VARCHAR(14), d.CD_SUSEP)            AS    DOC_CEDENTE,
                            CONVERT(VARCHAR(14), ci.NO_CGC)                AS    DOC_SACADO,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_NATUREZA, -- ANEXO 02
                            CONVERT(VARCHAR(4), NULL)                    AS    CD_MODALIDADE, -- ANEXO 03
                            CONVERT(VARCHAR(4), NULL)                    AS    CD_ORIG_RECURSOS, -- ANEXO 04
                            CONVERT(VARCHAR(25), RTRIM(LTRIM(d.IDDIR_CD)))
                                                                        AS    CD_INDEXADOR, -- ANEXO 05
                            CONVERT(VARCHAR(15), RTRIM(LTRIM(d.BAMDA_CD)))
                                                                        AS    CD_VAR_CAMB, -- ANEXO 06
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_CARAC_ESPEC, -- ANEXO 08
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 17
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_VINC_ME, -- ANEXO 18
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PRAZO_PROV, -- ANEXO 19
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_DESEMPENHO, -- ANEXO 28
							0                                           AS    IC_BAIXAR_ATIVO,
                            0                                           AS    IC_RECOMPRA
                FROM          BRLSAC.dbo.SAC_RF_OPERACAO          AS    c  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO            AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO              AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV               AS    m  with(nolock) ON (c.CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                  AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF               AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_CL_CPR               AS    mt with(nolock) ON (mt.CLCLI_CD = c.CLCLI_CD)
                WHERE        mt.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            c.CD                    = NULLIF(LEFT(
                                                    SUBSTRING(mt.DS, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', mt.DS), 8000),
                                                    PATINDEX('%[^0-9]%', SUBSTRING(mt.DS, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', mt.DS), 8000) + 'X') - 1), '')
    ) AS A
    INNER JOIN TB_3040_ATIVO	                    AS B    ON (A.TP_ATIVO COLLATE DATABASE_DEFAULT = B.CD_ATIVO AND B.ID_FUNDO = @idFundo)

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
    SELECT      TP_CLIENTE,
                CEP,
                CONG_ECONOMICO,
                VL_FAT_ANUAL,
                MIN(DT_INI_RELAC) AS DT_INI_RELAC,
                CD_LOCALIZACAO,
                CD_TP_CONTROLE,
                CD_TP_PESSOA,
                CD_RATING,
                CD_AUTORIZACAO,
                CD_PORTE_PJ,
                CD_PORTE_PF,
                COALESCE(DOC_CLIENTE, '99999999999999'),
                CASE WHEN DOC_CLIENTE IS NULL OR NM_CLIENTE IS NULL THEN 'Não informado' ELSE NM_CLIENTE END,
                IS_SFN
    FROM        (
                SELECT        'CEDENTE'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(d.CD_SUSEP) = 14 THEN '2'
                                                     WHEN d.CD_SUSEP IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(d.CD_SUSEP)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULL)                 AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                             AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_CL_PATRRF              AS    a  with(nolock) INNER JOIN
                            BRLSAC.dbo.SAC_RF_POS                 AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT) INNER JOIN
                            BRLSAC.dbo.SAC_RF_OPERACAO            AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD) INNER JOIN
                            BRLSAC.dbo.SAC_RF_LASTRO              AS    d  with(nolock) ON (c.RFLAS_CD = d.CD) INNER JOIN
                            BRLSAC.dbo.SAC_RF_TIPO                AS    t  with(nolock) ON (d.RFTP_CD = t.CD) INNER JOIN
                            BRLSAC.dbo.SAC_RF_MOV                 AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD) INNER JOIN
                            BRLSAC.dbo.CLI_BAS                    AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI) INNER JOIN
                            BRLSAC.dbo.BAS_CAD_IF                 AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                WHERE        a.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            p.QT_DISPONIVEL            <>    0
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND            d.SG_MTM                <>  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            NOT EXISTS (SELECT TOP 1 1 FROM BRLSAC.dbo.SAC_RF_MEMORIA AS mm WHERE mm.RFOP_CD = a.RFOP_CD AND mm.DT = a.DT AND mm.SG_CURVA = 'M')

                UNION ALL
    
                SELECT        'CEDENTE'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10    
                            CONVERT(VARCHAR(1), CASE WHEN LEN(d.CD_SUSEP) = 14 THEN '2'
                                                     WHEN d.CD_SUSEP IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(d.CD_SUSEP)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULL)                 AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                            AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_CL_PATRRF               AS    a  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_POS                AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN    BRLSAC.dbo.SAC_RF_OPERACAO           AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO             AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO               AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV                AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                   AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF                AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MEMORIA            AS    mm with(nolock) ON (a.RFOP_CD = mm.RFOP_CD AND mm.DT = a.DT)
                WHERE        a.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            p.QT_DISPONIVEL            <>    0
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND            d.SG_MTM                <>  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            EXISTS (SELECT TOP 1 1 FROM BRLSAC.dbo.SAC_RF_MEMORIA AS mm WHERE mm.RFOP_CD = a.RFOP_CD AND mm.DT = a.DT AND mm.SG_CURVA = 'M')
                AND            mm.SG_CURVA                =    'M'
    
                UNION ALL
    
                SELECT        'CEDENTE'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(d.CD_SUSEP) = 14 THEN '2'
                                                     WHEN d.CD_SUSEP IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(d.CD_SUSEP)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULL)                 AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                            AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_CL_PATRRF               AS    a  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_POS                AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN    BRLSAC.dbo.SAC_RF_OPERACAO           AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO             AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO               AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV                AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                   AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF                AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MEMORIA            AS    mm with(nolock) ON (a.RFOP_CD = mm.RFOP_CD AND mm.DT = a.DT)
                WHERE        a.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            p.QT_DISPONIVEL            <>    0
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND            d.SG_MTM                =  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
    
                UNION ALL

                SELECT        'CEDENTE'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(d.CD_SUSEP) = 14 THEN '2'
                                                     WHEN d.CD_SUSEP IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(d.CD_SUSEP)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULL)                 AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                             AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_RF_OPERACAO            AS    c  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO            AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO              AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV               AS    m  with(nolock) ON (c.CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                  AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF               AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_CL_CPR               AS    mt with(nolock) ON (mt.CLCLI_CD = c.CLCLI_CD)
                WHERE        mt.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            c.CD                    = NULLIF(LEFT(
                                                    SUBSTRING(mt.DS, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', mt.DS), 8000),
                                                    PATINDEX('%[^0-9]%', SUBSTRING(mt.DS, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', mt.DS), 8000) + 'X') - 1), '')

                UNION ALL
                                        
                SELECT        'SACADO'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(ci.NO_CGC) = 14 THEN '2'
                                                     WHEN ci.NO_CGC IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(ci.NO_CGC)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULLIF(LTRIM(RTRIM(ci.DS_RZSOCIAL)), ''))
                                                                         AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                            AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_CL_PATRRF             AS    a  with(nolock) INNER JOIN
                            BRLSAC.dbo.SAC_RF_POS                AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT) INNER JOIN
                            BRLSAC.dbo.SAC_RF_OPERACAO           AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD) INNER JOIN
                            BRLSAC.dbo.SAC_RF_LASTRO             AS    d  with(nolock) ON (c.RFLAS_CD = d.CD) INNER JOIN
                            BRLSAC.dbo.SAC_RF_TIPO               AS    t  with(nolock) ON (d.RFTP_CD = t.CD) INNER JOIN
                            BRLSAC.dbo.SAC_RF_MOV                AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD) INNER JOIN
                            BRLSAC.dbo.CLI_BAS                   AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI) INNER JOIN
                            BRLSAC.dbo.BAS_CAD_IF                AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                WHERE        a.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            p.QT_DISPONIVEL            <>    0
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND            d.SG_MTM                <>  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            NOT EXISTS (SELECT TOP 1 1 FROM BRLSAC.dbo.SAC_RF_MEMORIA AS mm WHERE mm.RFOP_CD = a.RFOP_CD AND mm.DT = a.DT AND mm.SG_CURVA = 'M')

                UNION ALL
    
                SELECT        'SACADO'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(ci.NO_CGC) = 14 THEN '2'
                                                     WHEN ci.NO_CGC IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(ci.NO_CGC)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULLIF(LTRIM(RTRIM(ci.DS_RZSOCIAL)), ''))
                                                                         AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                            AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_CL_PATRRF               AS    a  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_POS                AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN    BRLSAC.dbo.SAC_RF_OPERACAO           AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO             AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO               AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV                AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                   AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF                AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MEMORIA            AS    mm with(nolock) ON (a.RFOP_CD = mm.RFOP_CD AND mm.DT = a.DT)
                WHERE        a.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            p.QT_DISPONIVEL            <>    0
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND            d.SG_MTM                <>  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            EXISTS (SELECT TOP 1 1 FROM BRLSAC.dbo.SAC_RF_MEMORIA AS mm WHERE mm.RFOP_CD = a.RFOP_CD AND mm.DT = a.DT AND mm.SG_CURVA = 'M')
                AND            mm.SG_CURVA                =    'M'
    
                UNION ALL
    
                SELECT        'SACADO'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(ci.NO_CGC) = 14 THEN '2'
                                                     WHEN ci.NO_CGC IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(ci.NO_CGC)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULLIF(LTRIM(RTRIM(ci.DS_RZSOCIAL)), ''))
                                                                         AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                            AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_CL_PATRRF               AS    a  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_POS                AS    p  with(nolock) ON (a.RFOP_CD = p.RFOP_CD AND a.DT = p.DT)
                INNER JOIN    BRLSAC.dbo.SAC_RF_OPERACAO           AS    c  with(nolock) ON (a.RFOP_CD = c.CD AND a.CLCLI_CD = c.CLCLI_CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO             AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO               AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV                AS    m  with(nolock) ON (a.RFOP_CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                   AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF                AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MEMORIA            AS    mm with(nolock) ON (a.RFOP_CD = mm.RFOP_CD AND mm.DT = a.DT)
                WHERE        a.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            p.QT_DISPONIVEL            <>    0
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND            d.SG_MTM                =  'N'
                AND         d.IC_ATIVO_PASSIVO      =   'A'
    
                UNION ALL

                SELECT        'SACADO'                                    AS    TP_CLIENTE,
                            CONVERT(VARCHAR(8), NULL)                    AS    CEP,
                            CONVERT(VARCHAR(40), NULL)                    AS    CONG_ECONOMICO,
                            CONVERT(NUMERIC(19,4), NULL)                AS    VL_FAT_ANUAL,
                            CONVERT(DATE, m.DT)                            AS    DT_INI_RELAC,
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_LOCALIZACAO, -- ANEXO 07
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_TP_CONTROLE, -- ANEXO 10
                            CONVERT(VARCHAR(1), CASE WHEN LEN(ci.NO_CGC) = 14 THEN '2'
                                                     WHEN ci.NO_CGC IS NULL THEN '2'
                                                     ELSE '1' END)
                                                                        AS    CD_TP_PESSOA, -- ANEXO 11
                            CONVERT(VARCHAR(2), NULL)                    AS    CD_RATING, -- ANEXO 16
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_AUTORIZACAO, -- ANEXO 20
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PJ, -- ANEXO 24
                            CONVERT(VARCHAR(1), NULL)                    AS    CD_PORTE_PF, -- ANEXO 25
                            CONVERT(VARCHAR(14), NULLIF(LTRIM(RTRIM(ci.NO_CGC)), ''))
                                                                        AS    DOC_CLIENTE,
                            CONVERT(VARCHAR(100), NULLIF(LTRIM(RTRIM(ci.DS_RZSOCIAL)), ''))
                                                                         AS    NM_CLIENTE,
                            CONVERT(BIT, NULL)                            AS    IS_SFN
                FROM        BRLSAC.dbo.SAC_RF_OPERACAO            AS    c  with(nolock)
                INNER JOIN    BRLSAC.dbo.SAC_RF_LASTRO            AS    d  with(nolock) ON (c.RFLAS_CD = d.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_TIPO              AS    t  with(nolock) ON (d.RFTP_CD = t.CD)
                INNER JOIN    BRLSAC.dbo.SAC_RF_MOV               AS    m  with(nolock) ON (c.CD = m.RFOP_CD)
                INNER JOIN    BRLSAC.dbo.CLI_BAS                  AS    cl with(nolock) ON (c.CLCLI_CD = cl.CODCLI)
                INNER JOIN    BRLSAC.dbo.BAS_CAD_IF               AS    ci with(nolock) ON (d.BAINS_CD = ci.CODINST)
                INNER JOIN    BRLSAC.dbo.SAC_CL_CPR               AS    mt with(nolock) ON (mt.CLCLI_CD = c.CLCLI_CD)
                WHERE        mt.DT                    =    @dtPosicao
                AND            cl.CGC                    =    @cnpjFundo
                AND            m.SG_OPERACAO            IN    ('C', 'T')
                AND         d.IC_ATIVO_PASSIVO      =   'A'
                AND            c.CD                    = NULLIF(LEFT(
                                                    SUBSTRING(mt.DS, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', mt.DS), 8000),
                                                    PATINDEX('%[^0-9]%', SUBSTRING(mt.DS, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', mt.DS), 8000) + 'X') - 1), '')
    ) AS a
    GROUP BY    TP_CLIENTE,
                CEP,
                CONG_ECONOMICO,
                VL_FAT_ANUAL,
                CD_LOCALIZACAO,
                CD_TP_CONTROLE,
                CD_TP_PESSOA,
                CD_RATING,
                CD_AUTORIZACAO,
                CD_PORTE_PJ,
                CD_PORTE_PF,
                COALESCE(DOC_CLIENTE, '99999999999999'),
                CASE WHEN DOC_CLIENTE IS NULL OR NM_CLIENTE IS NULL THEN 'Não informado' ELSE NM_CLIENTE END,
                IS_SFN
    
    SET @qtImpCli = @@ROWCOUNT
    SET @dtImpCli = GETDATE()
	END
    IF (@debug = 1)
    BEGIN
        PRINT 'Total de clientes: ' + CONVERT(varchar, @qtImpCli)
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