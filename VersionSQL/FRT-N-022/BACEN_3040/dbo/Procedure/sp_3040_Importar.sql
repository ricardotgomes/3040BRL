/****** Object:  Procedure [dbo].[sp_3040_Importar]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_3040_Importar]
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
            @qtImpCli INT, 
            @dtImpCli DATETIME,
            @qtDpOp INT, 
            @dtDpOp DATETIME,
            @qtDpCli INT, 
            @dtDpCli DATETIME,
            @qtDlOp INT, 
            @dtDlOp DATETIME
    
    SET @inicio = GETDATE()
    SET @qtImpOp = 0
    SET @qtImpCli = 0
    SET @qtDpOp = 0
    SET @qtDpCli = 0
    SET @qtDlOp = 0
    
    DECLARE @cnpjFundo VARCHAR(14), @nomeFundo VARCHAR(100), @data DATETIME;

    --Dados nacessários para execução
    SELECT 
                @nomeFundo = NM_FUNDO,
                @data = GETDATE(), 
                @cnpjFundo = CD_CNPJ_FUNDO
    FROM        TB_3040_BAS_FUNDO
	WHERE 	ID_FUNDO = @idFundo

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

    -- Merge dos dados de cliente:
    -- Insere os clientes que não existem na base
    -- Atualiza os clientes que já existem na base -- TODO: definir um meio identificar qual a preferencia, se mantem as atualização do usuário ou se sobrescreve com o importado
    INSERT INTO    TB_3040_BAS_CLIENTE(
                ID_FUNDO,
                TP_CLIENTE,
                CEP,
                CONG_ECONOMICO,    
                VL_FAT_ANUAL,    
                DT_INI_RELAC,    
                ID_ANEXO_07,    
                ID_ANEXO_10,    
                ID_ANEXO_11,
                ID_ANEXO_16,    
                ID_ANEXO_20,    
                ID_ANEXO_24,    
                ID_ANEXO_25,
                DOC_CLIENTE,
                NM_CLIENTE,
                IS_SFN,
                CREATED_BY,
                CREATED_DATE,
                LAST_MODIFIED_BY,
                LAST_MODIFIED_DATE,
				CD_TP_PESSOA
                )
    SELECT      DISTINCT  
                d.ID_FUNDO,
                c.TP_CLIENTE,
                COALESCE(REPLICATE('0', 8 - LEN(c.CEP)) + RTRIM(c.CEP), '00000000'),
                c.CONG_ECONOMICO,
                COALESCE(c.VL_FAT_ANUAL, 0.01),
                c.DT_INI_RELAC,
                COALESCE(a07.ID_ANEXO_07, d.ID_ANEXO_07),
                COALESCE(a10.ID_ANEXO_10, d.ID_ANEXO_10),
                a11.ID_ANEXO_11,
                COALESCE(a16.ID_ANEXO_16, d.ID_ANEXO_16),
                COALESCE(a20.ID_ANEXO_20, d.ID_ANEXO_20),
                COALESCE(a24.ID_ANEXO_24, CASE WHEN a11.TP_PESSOA = 'J' THEN 1 ELSE NULL END),
                COALESCE(a25.ID_ANEXO_25, CASE WHEN a11.TP_PESSOA = 'F' THEN 1 ELSE NULL END),
                c.DOC_CLIENTE,
                c.NM_CLIENTE,
                COALESCE(c.IS_SFN, 0), --Por padrão não pertence ao SFN
                @user,
                @data,
                @user,
                @data,
				c.CD_TP_PESSOA
    FROM        TB_3040_IMP_CLIENTE                  AS    c
    INNER JOIN    TB_3040_DP_PADRAO                  AS    d      ON    (d.ID_FUNDO = @idFundo)
    LEFT JOIN    TB_3040_BAS_CLIENTE                 AS    cl     ON    (cl.TP_CLIENTE = c.TP_CLIENTE AND cl.DOC_CLIENTE = c.DOC_CLIENTE AND cl.ID_FUNDO = @idFundo)
    LEFT JOIN    TB_3040_ANEXO_07_LOCALIZACAO        AS    a07    ON    (a07.CD_ESTADO = c.CD_LOCALIZACAO)
    LEFT JOIN    TB_3040_ANEXO_10_TP_CONTROLE        AS    a10    ON    (a10.CD_TP_CONTROLE = c.CD_TP_CONTROLE)
    LEFT JOIN    TB_3040_ANEXO_11_TP_PESSOA          AS    a11    ON    (a11.CD_TP_PESSOA = c.CD_TP_PESSOA)
    LEFT JOIN    TB_3040_ANEXO_16_CLASS_RISCO_CLI    AS    a16    ON    (a16.CD_CLASS_RISCO_CLI = c.CD_RATING)
    LEFT JOIN    TB_3040_ANEXO_20_AUTORIZACAO        AS    a20    ON    (a20.CD_AUTORIZACAO = CASE WHEN c.CD_AUTORIZACAO IS NULL OR c.CD_AUTORIZACAO = 0 THEN 'N' ELSE 'S' END)
    LEFT JOIN    TB_3040_ANEXO_24_PORTE_CLIENTE_PJ   AS    a24    ON    (a24.CD_PORTE_CLIENTE = c.CD_PORTE_PJ)
    LEFT JOIN    TB_3040_ANEXO_25_PORTE_CLIENTE_PF   AS    a25    ON    (a25.CD_PORTE_CLIENTE = c.CD_PORTE_PF)
    WHERE        cl.DOC_CLIENTE IS NULL
    
    SET @qtDpCli = @@ROWCOUNT
    SET @dtDpCli = GETDATE()

    IF (@debug = 1)
    BEGIN
        PRINT 'Total de novos clientes: ' + CONVERT(varchar, @qtDpCli)
    END;


    -- Atualiza a data de inicio de relacionamento
    WITH RELAT_CLI AS (
        SELECT      1 AS ID_FUNDO, DOC_CLIENTE, TP_CLIENTE, MIN(DT_INI_RELAC) AS DT_INI_RELAC, CD_TP_PESSOA
        FROM        TB_3040_IMP_CLIENTE
        GROUP BY    DOC_CLIENTE, TP_CLIENTE, CD_TP_PESSOA
    )
    UPDATE          TB_3040_BAS_CLIENTE 
        SET         DT_INI_RELAC = imp.DT_INI_RELAC , CD_TP_PESSOA = imp.CD_TP_PESSOA
        FROM        TB_3040_BAS_CLIENTE AS cli
        INNER JOIN  RELAT_CLI           AS imp ON   (   cli.DOC_CLIENTE = imp.DOC_CLIENTE 
                                                    AND cli.TP_CLIENTE = imp.TP_CLIENTE 
                                                    AND cli.ID_FUNDO = IMP.ID_FUNDO)
        WHERE       imp.DT_INI_RELAC < cli.DT_INI_RELAC
		OR cli.CD_TP_PESSOA IS NULL
    
    SET @qtDpCli = @@ROWCOUNT
    SET @dtDpCli = GETDATE()

    IF (@debug = 1)
    BEGIN
        PRINT 'Total de clientes atualizados: ' + CONVERT(varchar, @qtDpCli)
    END


    -- Merge dos dados de operação:
    -- 1 - Insere as operações que não existem na base
    -- 2 - Atualiza as operações que já existem na base -- TODO: definir um meio identificar qual a preferencia, se mantem as atualização do usuário ou se sobrescreve com o importado
    -- 3 - Exclui as operações inconsistentes
    -- 4 - Atualiza as Informações adicionais
    
    DECLARE @NAT_04 INT, @NAT_05 INT, @NAT_02 INT, @NAT_03 INT, @NAT_15 INT, @NAT_12 INT
    
    SELECT @NAT_04 = ID_ANEXO_02 FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO WHERE CD_NATU_OPER = '04'
    SELECT @NAT_05 = ID_ANEXO_02 FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO WHERE CD_NATU_OPER = '05'
    SELECT @NAT_02 = ID_ANEXO_02 FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO WHERE CD_NATU_OPER = '02'
    SELECT @NAT_03 = ID_ANEXO_02 FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO WHERE CD_NATU_OPER = '03'
    SELECT @NAT_15 = ID_ANEXO_02 FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO WHERE CD_NATU_OPER = '15' -- HELDER ADICIONOU 07/07/17
	SELECT @NAT_12 = ID_ANEXO_02 FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO WHERE CD_NATU_OPER = '12' -- Adicionado em 17/04 solicitacao Gisele


	IF EXISTS (SELECT TOP 1 1 FROM TB_3040_BAS_OPERACAO WHERE  ID_FUNDO = @idFundo AND DT_POSICAO = @dtposicao)
	  DECLARE	@ER INT, 
  			@RC INT
  
  	WHILE 1=1
  	BEGIN
  
  		BEGIN TRAN 
  
  		DELETE 
  		TOP		(100000)
  		FROM	TB_3040_BAS_OPERACAO
  		WHERE	ID_FUNDO = @idFundo
  		AND		DT_POSICAO = @dtposicao
  
  		SELECT @ER = @@ERROR, @RC = @@ROWCOUNT
  
  		IF @ER <> 0
  		BEGIN
  			ROLLBACK
  			BREAK
  		END
  
  		IF @RC = 0
  		BEGIN
  			COMMIT
  			BREAK
  		END
  
  		COMMIT
    END

    INSERT INTO    TB_3040_BAS_OPERACAO(
                ID_FUNDO,
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
                ID_CEDENTE,
                ID_SACADO,
                ID_ANEXO_02,
                ID_ANEXO_03,
                ID_ANEXO_04,
                ID_ANEXO_05,
                ID_ANEXO_06,
                ID_ANEXO_08,
                ID_ANEXO_17,
                ID_ANEXO_18,
                ID_ANEXO_19,
                ID_ANEXO_28,
                FL_SUBSTITUIDO_FLUXO,
                CREATED_BY,
                CREATED_DATE,
                LAST_MODIFIED_BY,
                LAST_MODIFIED_DATE,
				DS_NU_DOCUMENTO,
				NUM_CONTRATO_C3,
				IC_BAIXAR_ATIVO,  
				IC_RECOMPRA,      
				VL_MOVIMENTACAO,  
				DT_MOVIMENTO,     
				NM_TIPO_MOVIMENTO
                )
    SELECT        
                d.ID_FUNDO,
                @dtPosicao,
                o.CD_CONTRATO_CEDENTE,
                o.CD_CONTRATO_SACADO,
                o.CD_LASTRO,
                o.DOC_ORIGINADOR,
                o.ID_SISTEMA_ORIGEM,
                o.CD_SISTEMA_ORIGEM,
                o.TP_ATIVO,
                COALESCE(o.DS_CONTA_COSIF, '1'),
                COALESCE(o.FL_COOBRIGACAO, 0),
                o.DT_AQUISICAO,
                o.DT_VENCIMENTO,
                o.TX_OPERACAO,
                o.VL_AQUISICAO,
                o.VL_NOMINAL,
                COALESCE(o.VL_PERC_COOBRIGACAO, d.VL_PERC_COOBRIGACAO),
                o.VL_PERC_SUBORDINACAO,
                o.VL_PDD,
                COALESCE(o.VL_PERC_INDEXADOR, d.VL_PERC_INDEXADOR),
                c.ID_CLIENTE,
                s.ID_CLIENTE,
                COALESCE(a02.ID_ANEXO_02, 
                    --CASE    WHEN o.FL_COOBRIGACAO = 1 AND c.IS_SFN = 1 THEN @NAT_04 
                    --        WHEN o.FL_COOBRIGACAO = 1 AND c.IS_SFN = 0 THEN @NAT_05 
                    --        WHEN o.FL_COOBRIGACAO = 0 AND c.IS_SFN = 1 THEN @NAT_02 
                    --        WHEN o.FL_COOBRIGACAO = 0 AND c.IS_SFN = 0 THEN @NAT_03 
                    --END, 
					d.ID_ANEXO_02),
                COALESCE(a03.ID_ANEXO_03, d.ID_ANEXO_03),
                COALESCE(a04.ID_ANEXO_04, d.ID_ANEXO_04),
                COALESCE(a05.ID_ANEXO_05, ref.ID_ANEXO_05, d.ID_ANEXO_05),
                COALESCE(a06.ID_ANEXO_06, vc.ID_ANEXO_06 ,d.ID_ANEXO_06),
                COALESCE(a08.ID_ANEXO_08, d.ID_ANEXO_08),
                COALESCE(a17.ID_ANEXO_17, d.ID_ANEXO_17),
                COALESCE(a18.ID_ANEXO_18, d.ID_ANEXO_18),
                COALESCE(a19.ID_ANEXO_19, d.ID_ANEXO_19),
                COALESCE(a28.ID_ANEXO_28, d.ID_ANEXO_28),
                0,
                @user,
                @data,
                @user,
                @data,
				o.DS_NU_DOCUMENTO,
				O.NUM_CONTRATO_C3,
				o.IC_BAIXAR_ATIVO,
				o.IC_RECOMPRA,
				o.VL_MOVIMENTACAO,
				o.DT_MOVIMENTO,
				o.NM_TIPO_MOVIMENTO
    FROM        TB_3040_IMP_OPERACAO                    AS    o
    INNER JOIN  TB_3040_DP_PADRAO                       AS    d    ON    (d.ID_FUNDO = @idFundo)
    INNER JOIN  TB_3040_BAS_CLIENTE                     AS    c    ON    (c.TP_CLIENTE = 'CEDENTE' AND c.DOC_CLIENTE = o.DOC_CEDENTE AND c.ID_FUNDO = @idFundo)
    INNER JOIN  TB_3040_BAS_CLIENTE                     AS    s    ON    (s.TP_CLIENTE = 'SACADO' AND s.DOC_CLIENTE = o.DOC_SACADO AND s.ID_FUNDO = @idFundo)
    LEFT JOIN   TB_3040_BAS_OPERACAO                    AS    op   ON    (op.ID_FUNDO            = @idFundo 
                                                                AND op.DT_POSICAO          = o.DT_POSICAO 
                                                                AND op.CD_CONTRATO_CEDENTE = o.CD_CONTRATO_CEDENTE
                                                                AND op.CD_CONTRATO_SACADO  = o.CD_CONTRATO_SACADO 
                                                                AND op.CD_SISTEMA_ORIGEM   = o.CD_SISTEMA_ORIGEM 
                                                                AND op.TP_ATIVO            = o.TP_ATIVO
                                                                AND op.VL_AQUISICAO        = o.VL_AQUISICAO
                                                                AND op.FL_SUBSTITUIDO_FLUXO = 0)
    LEFT JOIN    TB_3040_ANEXO_02_NATUREZA_OPERACAO     AS    a02    ON    (a02.CD_NATU_OPER = o.CD_NATUREZA)
    LEFT JOIN    TB_3040_ANEXO_03_MODALIDADE_OPERACAO   AS    a03    ON    (a03.CD_MODALIDADE + a03.CD_SUB_MODALIDADE = o.CD_MODALIDADE)
    LEFT JOIN    TB_3040_ANEXO_04_ORIGEM_RECURSO      AS    a04    ON    (a04.CD_ORIGEM_RECURSOS + a04.CD_SUB_ORIGEM_RECURSOS = o.CD_ORIG_RECURSOS)
    LEFT JOIN    TB_3040_ANEXO_05_TAXA_REF_INDEXADOR    AS    a05    ON    (    LOWER(a05.DS_SUB_TAXA_REF) COLLATE DATABASE_DEFAULT = LOWER(o.CD_INDEXADOR) COLLATE DATABASE_DEFAULT
                                                                            OR  a05.CD_TAXA_REF + a05.CD_SUB_TAXA_REF COLLATE DATABASE_DEFAULT = o.CD_INDEXADOR COLLATE DATABASE_DEFAULT)
    LEFT JOIN    TB_3040_ANEXO_06_VAR_CAMBIAL           AS    a06    ON    (    LOWER(a06.DS_VAR_CAMBIAL) COLLATE DATABASE_DEFAULT = LOWER(o.CD_VAR_CAMB) COLLATE DATABASE_DEFAULT
                                                                            OR  a06.CD_VAR_CAMBIAL COLLATE DATABASE_DEFAULT = o.CD_VAR_CAMB COLLATE DATABASE_DEFAULT)
    LEFT JOIN    TB_3040_ANEXO_08_CARAC_ESPECIAL        AS    a08    ON    (a08.CD_CARAC_ESPECIAL = o.CD_CARAC_ESPEC)
    LEFT JOIN    TB_3040_ANEXO_17_CLASS_RISCO_OPER      AS    a17    ON    (a17.CD_CLASS_RISCO_OPER = o.CD_RATING)
    LEFT JOIN    TB_3040_ANEXO_18_VINC_ME               AS    a18    ON    (a18.CD_VINC_ME = o.CD_VINC_ME)
    LEFT JOIN    TB_3040_ANEXO_19_PRAZO_PROV            AS    a19    ON    (a19.CD_PRAZO_PROV = o.CD_PRAZO_PROV)
    LEFT JOIN    TB_3040_ANEXO_28_DES_OPERACAO          AS    a28    ON    (a28.CD_DES_OPERACAO = o.CD_DESEMPENHO)
    LEFT JOIN    TB_3040_DE_PARA_VAR_CAMBIAL            AS    vc     ON    (vc.DS_VAR_CAMBIAL = o.CD_VAR_CAMB)
    LEFT JOIN    TB_3040_DE_PARA_TAXA_REF_INDEXADOR     AS    ref    ON    (ref.DS_TAXA_REF_INDEXADOR = o.CD_INDEXADOR)
    WHERE        op.ID_OPERACAO IS NULL
        
    SET @qtDpOp = @@ROWCOUNT
    SET @dtDpOp = GETDATE()

    IF (@debug = 1)
    BEGIN
        PRINT 'Total de novas operações: ' + CONVERT(varchar, @qtDpOp)
    END

    -- Exclui as operações inconsistentes
    --DELETE FROM TB_3040_BAS_OPERACAO
    --WHERE ID_OPERACAO IN (
    --    SELECT        op.ID_OPERACAO 
    --    FROM        TB_3040_BAS_OPERACAO    AS    op
    --    INNER JOIN    TB_3040_BAS_FUNDO        AS    f    ON (f.ID_FUNDO = @idFundo)
    --    LEFT JOIN    TB_3040_IMP_OPERACAO    AS    o    ON    (o.CNPJ_FUNDO            = f.CD_CNPJ_FUNDO
    --                                                AND op.DT_POSICAO            = o.DT_POSICAO 
    --                                                AND op.CD_CONTRATO_CEDENTE    = o.CD_CONTRATO_CEDENTE
    --                                                AND op.CD_CONTRATO_SACADO    = o.CD_CONTRATO_SACADO 
    --                                                AND op.CD_SISTEMA_ORIGEM    = o.CD_SISTEMA_ORIGEM 
    --                                                AND op.TP_ATIVO                = o.TP_ATIVO
    --                                                AND op.VL_AQUISICAO            = o.VL_AQUISICAO
    --                                                AND op.CD_SISTEMA_ORIGEM  IN ( 'SAC','AMPLIS','PAS') )
													
    --    WHERE    op.DT_POSICAO = @dtPosicao
    --    AND        (o.CNPJ_FUNDO IS NULL
    --    OR      op.FL_SUBSTITUIDO_FLUXO = 1)) 
    --AND ID_FUNDO = @idFundo
    --AND CD_SISTEMA_ORIGEM IN ( 'SAC','AMPLIS','PAS')

    
    SET @qtDlOp = @@ROWCOUNT
    SET @dtDlOp = GETDATE()

    IF (@debug = 1)
    BEGIN
        PRINT 'Total de operações excluídas: ' + CONVERT(varchar, @qtDlOp)
    END

    TRUNCATE TABLE TB_3040_IMP_OPERACAO
    TRUNCATE TABLE TB_3040_IMP_CLIENTE

    IF (@debug = 1)
    BEGIN
        PRINT 'Tempo decorrido: ' + CONVERT(VARCHAR, GETDATE() - @inicio, 14)
        PRINT 'Importação executada com sucesso'
        PRINT ''
    END

       
    SET @cdError = 0
    SET @dsError = 'Importação executada com sucesso'
    RETURN @cdError
END