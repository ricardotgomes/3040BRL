/****** Object:  Function [dbo].[fn_Cessao]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[fn_Cessao]
(
    @id_fundo int, 
    @data smalldatetime
)
RETURNS 
@tabela TABLE 
(
    ID_FUNDO                int NOT NULL,
    DT_POSICAO                date NOT NULL,
    CD_CONTRATO_CEDENTE        varchar(100) NOT NULL,
    DOC_ORIGINADOR            varchar(14) NULL,
    CD_SISTEMA_ORIGEM        varchar(10) NOT NULL,
    TIPO                    varchar(10) NOT NULL,
    FL_COOBRIGACAO            bit NOT NULL,
    DT_AQUISICAO            date NOT NULL,
    TX_OPERACAO                numeric(25, 10) NOT NULL,
    VL_CONTRATO                numeric(19, 4) NOT NULL,
    VL_NOMINAL                numeric(19, 4) NOT NULL,
    VL_PERC_COOBRIGACAO        numeric(10, 7) NULL,
    VL_PERC_SUBORDINACAO    numeric(10, 7) NULL,
    VL_PDD                    numeric(19, 4) NOT NULL,
    ID_CEDENTE                bigint NOT NULL,
    DOC_CLIENTE                varchar(14) NOT NULL
)
AS
BEGIN
        
    INSERT    INTO @tabela
    (
                ID_FUNDO,
                DT_POSICAO,
                CD_CONTRATO_CEDENTE,
                DOC_ORIGINADOR,
                CD_SISTEMA_ORIGEM,
                TIPO,
                FL_COOBRIGACAO,
                DT_AQUISICAO,
                TX_OPERACAO,
                VL_CONTRATO,
                VL_NOMINAL,
                VL_PERC_COOBRIGACAO,
                VL_PERC_SUBORDINACAO,
                VL_PDD,
                ID_CEDENTE,
                DOC_CLIENTE
    )
    SELECT        
                O.ID_FUNDO,
                O.DT_POSICAO,
                O.CD_CONTRATO_CEDENTE,
                O.DOC_ORIGINADOR,
                O.CD_SISTEMA_ORIGEM,
                'Cessão'                AS TIPO,
                O.FL_COOBRIGACAO,
                O.DT_AQUISICAO,
                O.TX_OPERACAO,
                SUM(O.VL_AQUISICAO)     AS VL_CONTRATO,
                SUM(O.VL_NOMINAL)       AS VL_NOMINAL,
                O.VL_PERC_COOBRIGACAO,
                O.VL_PERC_SUBORDINACAO,
                SUM(O.VL_PDD)           AS VL_PDD,
                O.ID_CEDENTE,
                C.DOC_CLIENTE
    FROM        TB_3040_BAS_OPERACAO    AS O
    INNER JOIN    TB_3040_BAS_CLIENTE   AS C ON (O.ID_CEDENTE = C.ID_CLIENTE)
    WHERE        O.ID_FUNDO = @id_fundo
    AND            O.DT_POSICAO = @data
    AND         O.FL_SUBSTITUIDO_FLUXO = 0
    GROUP BY    O.ID_FUNDO,
                O.DT_POSICAO,
                O.CD_CONTRATO_CEDENTE,
                O.DOC_ORIGINADOR,
                O.CD_SISTEMA_ORIGEM,
                O.FL_COOBRIGACAO,
                O.DT_AQUISICAO,
                O.TX_OPERACAO,
                O.VL_PERC_COOBRIGACAO,
                O.VL_PERC_SUBORDINACAO,
                O.ID_CEDENTE,
                C.DOC_CLIENTE
        
    UPDATE @tabela SET VL_CONTRATO = F.VL_AQUISICAO, VL_PDD = F.VL_PDD
    FROM @tabela AS O
    INNER  JOIN  TB_3040_BAS_OPERACAO    AS F ON (   O.ID_FUNDO = F.ID_FUNDO
                                                AND O.DT_POSICAO = F.DT_POSICAO
                                                AND O.CD_CONTRATO_CEDENTE = F.CD_CONTRATO_CEDENTE
                                                AND O.CD_SISTEMA_ORIGEM = F.CD_SISTEMA_ORIGEM
                                                AND O.TIPO = F.TP_ATIVO
                                                AND F.FL_SUBSTITUIDO_FLUXO = 1) 
    RETURN 
END