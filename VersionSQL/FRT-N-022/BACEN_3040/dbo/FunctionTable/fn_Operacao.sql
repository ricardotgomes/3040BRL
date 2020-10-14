/****** Object:  Function [dbo].[fn_Operacao]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[fn_Operacao]
(
    @id_fundo int, 
    @data smalldatetime
)
RETURNS 
@tabela TABLE 
(
    ID_FUNDO                int NOT NULL,
    DT_POSICAO                date NOT NULL,
    CD_CONTRATO                varchar(100) NOT NULL,
    DOC_ORIGINADOR            varchar(14) NULL,
    CD_SISTEMA_ORIGEM        varchar(10) NOT NULL,
    TIPO                    varchar(40) NOT NULL,
    DS_CONTA_COSIF            VARCHAR(100) NOT NULL,
    DT_AQUISICAO            date NOT NULL,
    DT_VENCIMENTO            date NOT NULL,
    TX_OPERACAO                numeric(25, 10) NOT NULL,
    FL_COOBRIGACAO            bit NOT NULL,
    VL_CONTRATO                numeric(19, 4) NOT NULL,
    VL_NOMINAL                numeric(19, 4) NOT NULL,
    VL_PERC_COOBRIGACAO        numeric(10, 7) NULL,
    VL_PERC_SUBORDINACAO    numeric(10, 7) NULL,
    VL_PDD                    numeric(19, 4) NOT NULL,
    VL_PERC_INDEXADOR        numeric(5, 2) NOT NULL,
    ID_CLIENTE                bigint NOT NULL,
    DOC_CLIENTE                varchar(14) NOT NULL,
    ID_CEDENTE                bigint NOT NULL,
    ID_ANEXO_02                int NOT NULL,
    CD_ANEXO_02                varchar(2) NOT NULL,
    ID_ANEXO_03                int NOT NULL,
    CD_ANEXO_03                varchar(4) NOT NULL,
    ID_ANEXO_04                int NOT NULL,
    CD_ANEXO_04                varchar(4) NOT NULL,
    ID_ANEXO_05                int NOT NULL,
    CD_ANEXO_05                varchar(2) NOT NULL,
    ID_ANEXO_06                int NOT NULL,
    CD_ANEXO_06                varchar(3) NOT NULL,
    ID_ANEXO_08                int NULL,
    CD_ANEXO_08                varchar(2) NULL,
    ID_ANEXO_17                int NOT NULL,
    CD_ANEXO_17                varchar(2) NOT NULL,
    ID_ANEXO_18                int NOT NULL,
    CD_ANEXO_18                varchar(1) NOT NULL,
    ID_ANEXO_19                int NOT NULL,
    CD_ANEXO_19                varchar(1) NOT NULL,
    ID_ANEXO_28                int NOT NULL,
    CD_ANEXO_28                varchar(2) NOT NULL,
    ID_OPERACAO                int NULL,
	NUM_CONTRATO_C3            VARCHAR(21),
	IC_BAIXAR_ATIVO            BIT NOT NULL DEFAULT 0,
	IC_RECOMPRA      		   BIT NOT NULL DEFAULT 0,
	VL_MOVIMENTACAO  		   NUMERIC(17,2),
	DT_MOVIMENTO     		   SMALLDATETIME,
	NM_TIPO_MOVIMENTO		   VARCHAR(100)
)
AS
BEGIN

    INSERT    INTO @tabela
    (
                ID_FUNDO,
                DT_POSICAO,
                CD_CONTRATO,
                DOC_ORIGINADOR,
                CD_SISTEMA_ORIGEM,
                TIPO,
                DS_CONTA_COSIF,
                DT_AQUISICAO,
                DT_VENCIMENTO,
                TX_OPERACAO,
                FL_COOBRIGACAO,
                VL_CONTRATO,
                VL_NOMINAL,
                VL_PERC_COOBRIGACAO,
                VL_PERC_SUBORDINACAO,
                VL_PDD,
                VL_PERC_INDEXADOR,
                ID_CLIENTE,
                DOC_CLIENTE,
                ID_CEDENTE,
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
				NUM_CONTRATO_C3,
				IC_BAIXAR_ATIVO,
				IC_RECOMPRA,
				VL_MOVIMENTACAO,
				DT_MOVIMENTO,
				NM_TIPO_MOVIMENTO 
    )
    SELECT      o.ID_FUNDO,
                o.DT_POSICAO,
                o.CD_CONTRATO_CEDENTE        AS CD_CONTRATO,
                o.DOC_ORIGINADOR,
                o.CD_SISTEMA_ORIGEM,
                'Cessão'                AS TIPO,
                o.DS_CONTA_COSIF,
                o.DT_AQUISICAO,
                MAX(o.DT_VENCIMENTO)        AS DT_VENCIMENTO,
                o.TX_OPERACAO,
                o.FL_COOBRIGACAO,
                SUM(O.VL_AQUISICAO)        AS VL_CONTRATO,
                SUM(o.VL_NOMINAL)            AS VL_NOMINAL,
                o.VL_PERC_COOBRIGACAO,
                o.VL_PERC_SUBORDINACAO,
                SUM(O.VL_PDD)                AS VL_PDD,
                o.VL_PERC_INDEXADOR,
                o.ID_CEDENTE                AS ID_CLIENTE,
                (SELECT DOC_CLIENTE FROM TB_3040_BAS_CLIENTE AS C WHERE C.ID_CLIENTE = O.ID_CEDENTE),
                o.ID_CEDENTE               AS ID_CEDENTE,
                o.ID_ANEXO_02,
                (SELECT CD_NATU_OPER FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO AS A2 WHERE A2.ID_ANEXO_02 = O.ID_ANEXO_02),
                o.ID_ANEXO_03,
                (SELECT CD_MODALIDADE + CD_SUB_MODALIDADE FROM TB_3040_ANEXO_03_MODALIDADE_OPERACAO AS A3 WHERE A3.ID_ANEXO_03 = O.ID_ANEXO_03),
                o.ID_ANEXO_04,
                (SELECT CD_ORIGEM_RECURSOS + '00' FROM TB_3040_ANEXO_04_ORIGEM_RECURSO AS A4 WHERE A4.ID_ANEXO_04 = O.ID_ANEXO_04),
                o.ID_ANEXO_05,
                (SELECT CD_TAXA_REF + CD_SUB_TAXA_REF FROM TB_3040_ANEXO_05_TAXA_REF_INDEXADOR AS A5 WHERE A5.ID_ANEXO_05 = O.ID_ANEXO_05),
                o.ID_ANEXO_06,
                (SELECT CD_VAR_CAMBIAL FROM TB_3040_ANEXO_06_VAR_CAMBIAL AS A6 WHERE A6.ID_ANEXO_06 = O.ID_ANEXO_06),
                o.ID_ANEXO_08,
                (SELECT CD_CARAC_ESPECIAL FROM TB_3040_ANEXO_08_CARAC_ESPECIAL AS A8 WHERE A8.ID_ANEXO_08 = O.ID_ANEXO_08),
                o.ID_ANEXO_17,
                (SELECT CD_CLASS_RISCO_OPER FROM TB_3040_ANEXO_17_CLASS_RISCO_OPER AS A17 WHERE A17.ID_ANEXO_17 = O.ID_ANEXO_17),
                o.ID_ANEXO_18,
                (SELECT CD_VINC_ME FROM TB_3040_ANEXO_18_VINC_ME AS A18 WHERE A18.ID_ANEXO_18 = O.ID_ANEXO_18),
                o.ID_ANEXO_19,
                (SELECT CD_PRAZO_PROV FROM TB_3040_ANEXO_19_PRAZO_PROV AS A19 WHERE A19.ID_ANEXO_19 = O.ID_ANEXO_19),
               		CASE WHEN (DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 0 AND 14) OR DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) < 0
						THEN 1
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 15 AND 30
						THEN 2
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 31 AND 60
						THEN 3
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 61 AND 90
						THEN 4
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING <> 'WO'  or o.CD_RATING IS NULL
						THEN 5
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING = 'WO'
						THEN 6
					END,
                (SELECT CD_DES_OPERACAO FROM TB_3040_ANEXO_28_DES_OPERACAO AS A28 WHERE A28.ID_ANEXO_28 =  CASE WHEN (DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 0 AND 14) OR DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) < 0
						THEN 1
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 15 AND 30
						THEN 2
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 31 AND 60
						THEN 3
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 61 AND 90
						THEN 4
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING <> 'WO'  or o.CD_RATING IS NULL
						THEN 5
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING = 'WO'
						THEN 6
					END),
                o.ID_OPERACAO,
				o.NUM_CONTRATO_C3,
				o.IC_BAIXAR_ATIVO,
				o.IC_RECOMPRA,      
				o.VL_MOVIMENTACAO,  
				o.DT_MOVIMENTO,     
				o.NM_TIPO_MOVIMENTO
    FROM        TB_3040_BAS_OPERACAO    AS o
    WHERE        o.FL_COOBRIGACAO = 1
    AND            o.ID_FUNDO = @id_fundo
    AND            o.DT_POSICAO = @data
    AND         o.FL_SUBSTITUIDO_FLUXO = 0
    GROUP BY    o.ID_FUNDO,
                o.DT_POSICAO,
                o.CD_CONTRATO_CEDENTE,
                o.DOC_ORIGINADOR,
                o.CD_SISTEMA_ORIGEM,
                o.DS_CONTA_COSIF,
                o.DT_AQUISICAO,
                o.TX_OPERACAO,
                o.FL_COOBRIGACAO,
                o.VL_PERC_COOBRIGACAO,
                o.VL_PERC_SUBORDINACAO,
                o.VL_PERC_INDEXADOR,
                o.ID_CEDENTE,
                o.ID_ANEXO_02,
                o.ID_ANEXO_03,
                o.ID_ANEXO_04,
                o.ID_ANEXO_05,
                o.ID_ANEXO_06,
                o.ID_ANEXO_08,
                o.ID_ANEXO_17,
                o.ID_ANEXO_18,
                o.ID_ANEXO_19,
                o.ID_ANEXO_28,
                o.ID_OPERACAO,
				o.DT_VENCIMENTO,
				o.DT_POSICAO,
				O.CD_RATING,
				o.NUM_CONTRATO_C3,
				o.IC_BAIXAR_ATIVO,
				o.IC_RECOMPRA,      
				o.VL_MOVIMENTACAO,  
				o.DT_MOVIMENTO,     
				o.NM_TIPO_MOVIMENTO

    UPDATE @tabela SET VL_CONTRATO = F.VL_AQUISICAO, VL_PDD = F.VL_PDD
    FROM @tabela AS O
    INNER  JOIN  TB_3040_BAS_OPERACAO    AS F ON (   O.ID_FUNDO = F.ID_FUNDO
                                                AND O.DT_POSICAO = F.DT_POSICAO
                                                AND O.CD_CONTRATO = F.CD_CONTRATO_CEDENTE
                                                AND O.CD_SISTEMA_ORIGEM = F.CD_SISTEMA_ORIGEM
                                                AND O.TIPO = F.TP_ATIVO
                                                AND F.FL_SUBSTITUIDO_FLUXO = 1) 

    INSERT    INTO @tabela
    (
                ID_FUNDO,
                DT_POSICAO,
                CD_CONTRATO,
                DOC_ORIGINADOR,
                CD_SISTEMA_ORIGEM,
                TIPO,
                DS_CONTA_COSIF,
                DT_AQUISICAO,
                DT_VENCIMENTO,
                TX_OPERACAO,
                FL_COOBRIGACAO,
                VL_CONTRATO,
                VL_NOMINAL,
                VL_PERC_COOBRIGACAO,
                VL_PERC_SUBORDINACAO,
                VL_PDD,
                VL_PERC_INDEXADOR,
                ID_CLIENTE,
                DOC_CLIENTE,
                ID_CEDENTE,
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
				NUM_CONTRATO_C3,
				IC_BAIXAR_ATIVO,  
				IC_RECOMPRA,      
				VL_MOVIMENTACAO,  
				DT_MOVIMENTO,     
				NM_TIPO_MOVIMENTO
    )
    SELECT      o.ID_FUNDO,
                o.DT_POSICAO,
                o.CD_CONTRATO_SACADO        AS CD_CONTRATO,
                o.DOC_ORIGINADOR,
                o.CD_SISTEMA_ORIGEM,
                o.TP_ATIVO                AS TIPO,
                o.DS_CONTA_COSIF,
                o.DT_AQUISICAO,
                o.DT_VENCIMENTO,
                o.TX_OPERACAO,
                o.FL_COOBRIGACAO,
                COALESCE(NULLIF(o.VL_AQUISICAO, 0), 
                    CASE ROW_NUMBER() OVER (PARTITION BY o.ID_FUNDO, o.DT_POSICAO, o.CD_CONTRATO_SACADO ORDER BY o.ID_OPERACAO) WHEN 1 THEN f.VL_AQUISICAO ELSE 0.0 END, 0.0)
                                                                AS VL_CONTRATO,
                        o.VL_NOMINAL,
                        o.VL_PERC_COOBRIGACAO,
                        o.VL_PERC_SUBORDINACAO,
                COALESCE(NULLIF(o.VL_PDD, 0), 
                    CASE ROW_NUMBER() OVER (PARTITION BY o.ID_FUNDO, o.DT_POSICAO, o.CD_CONTRATO_SACADO ORDER BY o.ID_OPERACAO) WHEN 1 THEN f.VL_PDD ELSE 0.0 END, 0.0)
                                                                AS VL_PDD,
                o.VL_PERC_INDEXADOR,
                o.ID_SACADO                AS ID_CLIENTE,
                (SELECT DOC_CLIENTE FROM TB_3040_BAS_CLIENTE AS S WHERE S.ID_CLIENTE = O.ID_SACADO),
                o.ID_CEDENTE               AS ID_CEDENTE,
                o.ID_ANEXO_02,
                (SELECT CD_NATU_OPER FROM TB_3040_ANEXO_02_NATUREZA_OPERACAO AS A2 WHERE A2.ID_ANEXO_02 = O.ID_ANEXO_02),
                o.ID_ANEXO_03,
                (SELECT CD_MODALIDADE + CD_SUB_MODALIDADE FROM TB_3040_ANEXO_03_MODALIDADE_OPERACAO AS A3 WHERE A3.ID_ANEXO_03 = O.ID_ANEXO_03),
                o.ID_ANEXO_04,
                (SELECT CD_ORIGEM_RECURSOS + '00' FROM TB_3040_ANEXO_04_ORIGEM_RECURSO AS A4 WHERE A4.ID_ANEXO_04 = O.ID_ANEXO_04),
                o.ID_ANEXO_05,
                (SELECT CD_TAXA_REF + CD_SUB_TAXA_REF FROM TB_3040_ANEXO_05_TAXA_REF_INDEXADOR AS A5 WHERE A5.ID_ANEXO_05 = O.ID_ANEXO_05),
                o.ID_ANEXO_06,
                (SELECT CD_VAR_CAMBIAL FROM TB_3040_ANEXO_06_VAR_CAMBIAL AS A6 WHERE A6.ID_ANEXO_06 = O.ID_ANEXO_06),
                o.ID_ANEXO_08,
                (SELECT CD_CARAC_ESPECIAL FROM TB_3040_ANEXO_08_CARAC_ESPECIAL AS A8 WHERE A8.ID_ANEXO_08 = O.ID_ANEXO_08),
                o.ID_ANEXO_17,
                (SELECT CD_CLASS_RISCO_OPER FROM TB_3040_ANEXO_17_CLASS_RISCO_OPER AS A17 WHERE A17.ID_ANEXO_17 = O.ID_ANEXO_17),
                o.ID_ANEXO_18,
                (SELECT CD_VINC_ME FROM TB_3040_ANEXO_18_VINC_ME AS A18 WHERE A18.ID_ANEXO_18 = O.ID_ANEXO_18),
                o.ID_ANEXO_19,
                (SELECT CD_PRAZO_PROV FROM TB_3040_ANEXO_19_PRAZO_PROV AS A19 WHERE A19.ID_ANEXO_19 = O.ID_ANEXO_19),
               		CASE WHEN (DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 0 AND 14) OR DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) < 0
						THEN 1
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 15 AND 30
						THEN 2
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 31 AND 60
						THEN 3
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 61 AND 90
						THEN 4
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING <> 'WO' or o.CD_RATING IS NULL
						THEN 5
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING = 'WO'
						THEN 6
					END,
                (SELECT CD_DES_OPERACAO FROM TB_3040_ANEXO_28_DES_OPERACAO AS A28 WHERE A28.ID_ANEXO_28 =  CASE WHEN (DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 0 AND 14) OR DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) < 0
						THEN 1
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 15 AND 30
						THEN 2
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 31 AND 60
						THEN 3
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) BETWEEN 61 AND 90
						THEN 4
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING <> 'WO' or o.CD_RATING IS NULL
						THEN 5
					WHEN DATEDIFF(DD,o.DT_VENCIMENTO,o.DT_POSICAO) > 90 AND o.CD_RATING = 'WO'
						THEN 6
					END),
                o.ID_OPERACAO,
				o.NUM_CONTRATO_C3,
				o.IC_BAIXAR_ATIVO,
				o.IC_RECOMPRA,      
				o.VL_MOVIMENTACAO,  
				o.DT_MOVIMENTO,     
				o.NM_TIPO_MOVIMENTO
    FROM        TB_3040_BAS_OPERACAO                    AS o
    LEFT JOIN   TB_3040_BAS_OPERACAO                    AS F    ON (    O.ID_FUNDO = F.ID_FUNDO
                                                                    AND O.DT_POSICAO = F.DT_POSICAO
                                                                    AND O.CD_CONTRATO_CEDENTE = F.CD_CONTRATO_CEDENTE
                                                                    AND O.CD_SISTEMA_ORIGEM = F.CD_SISTEMA_ORIGEM
                                                                    AND O.TP_ATIVO = F.TP_ATIVO
                                                                    AND F.FL_SUBSTITUIDO_FLUXO = 1) 
    WHERE       o.FL_COOBRIGACAO = 0
    AND         o.ID_FUNDO = @id_fundo
    AND         o.DT_POSICAO = @data
    AND         o.FL_SUBSTITUIDO_FLUXO = 0

    RETURN 
END