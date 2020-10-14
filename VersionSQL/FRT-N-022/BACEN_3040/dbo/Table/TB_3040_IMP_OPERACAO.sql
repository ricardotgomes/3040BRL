/****** Object:  Table [dbo].[TB_3040_IMP_OPERACAO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_IMP_OPERACAO](
	[ID_3040_IMP_OPERACAO] [bigint] IDENTITY(1,1) NOT NULL,
	[CNPJ_FUNDO] [varchar](14) NOT NULL,
	[DT_POSICAO] [date] NOT NULL,
	[CD_CONTRATO_CEDENTE] [varchar](100) NOT NULL,
	[CD_CONTRATO_SACADO] [varchar](100) NOT NULL,
	[CD_LASTRO] [varchar](100) NULL,
	[DOC_ORIGINADOR] [varchar](14) NULL,
	[ID_SISTEMA_ORIGEM] [varchar](100) NULL,
	[CD_SISTEMA_ORIGEM] [varchar](10) NULL,
	[TP_ATIVO] [varchar](40) NOT NULL,
	[DS_CONTA_COSIF] [varchar](100) NULL,
	[FL_COOBRIGACAO] [bit] NULL,
	[DT_AQUISICAO] [date] NOT NULL,
	[DT_VENCIMENTO] [date] NULL,
	[TX_OPERACAO] [numeric](25, 10) NOT NULL,
	[VL_AQUISICAO] [numeric](19, 4) NULL,
	[VL_NOMINAL] [numeric](19, 4) NULL,
	[VL_PERC_COOBRIGACAO] [numeric](10, 7) NULL,
	[VL_PERC_SUBORDINACAO] [numeric](10, 7) NULL,
	[VL_PDD] [numeric](19, 4) NOT NULL,
	[VL_PERC_INDEXADOR] [numeric](5, 2) NULL,
	[DOC_CEDENTE] [bigint] NOT NULL,
	[DOC_SACADO] [bigint] NOT NULL,
	[CD_NATUREZA] [varchar](255) NULL,
	[CD_MODALIDADE] [varchar](255) NULL,
	[CD_ORIG_RECURSOS] [varchar](255) NULL,
	[CD_INDEXADOR] [varchar](255) NULL,
	[CD_VAR_CAMB] [varchar](255) NULL,
	[CD_CARAC_ESPEC] [varchar](255) NULL,
	[CD_RATING] [varchar](255) NULL,
	[CD_VINC_ME] [varchar](255) NULL,
	[CD_PRAZO_PROV] [varchar](255) NULL,
	[CD_DESEMPENHO] [varchar](255) NULL,
	[DS_NU_DOCUMENTO] [varchar](100) NULL,
	[NUM_CONTRATO_C3] [varchar](21) NULL,
	[IC_BAIXAR_ATIVO] [bit] NOT NULL,
	[IC_RECOMPRA] [bit] NOT NULL,
	[VL_MOVIMENTACAO] [numeric](17, 2) NULL,
	[DT_MOVIMENTO] [smalldatetime] NULL,
	[NM_TIPO_MOVIMENTO] [varchar](100) NULL,
	[ID_ARQUIVO] [int] NULL,
	[ID_RECEBIVEL] [bigint] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_IMP_OPERACAO] ADD  DEFAULT ((0)) FOR [IC_BAIXAR_ATIVO]
ALTER TABLE [dbo].[TB_3040_IMP_OPERACAO] ADD  DEFAULT ((0)) FOR [IC_RECOMPRA]