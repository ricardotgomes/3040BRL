/****** Object:  Table [dbo].[TB_3040_ARQUIVO_DP_FLUXO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_ARQUIVO_DP_FLUXO](
	[ID_ARQUIVO_FLUXO] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_ARQUIVO] [int] NOT NULL,
	[CD_OPERACAO] [varchar](100) NOT NULL,
	[DS_CONTA_CETIP] [varchar](100) NOT NULL,
	[DT_VENCIMENTO] [date] NOT NULL,
	[DT_AQUISICAO] [date] NULL,
	[VL_AQUISICAO] [numeric](19, 4) NULL,
	[VL_LIQUIDO] [numeric](19, 4) NOT NULL,
	[VL_PDD] [numeric](19, 4) NULL,
	[DOC_CEDENTE] [varchar](14) NULL,
	[NM_CEDENTE] [varchar](100) NULL,
	[DOC_SACADO] [varchar](14) NULL,
	[NM_SACADO] [varchar](100) NULL,
	[DS_SEGMENTO] [varchar](100) NULL,
	[CD_NATUREZA] [varchar](2) NULL,
	[CD_MODALIDADE] [varchar](4) NULL,
	[TX_EFETIVA_ANUAL] [numeric](10, 7) NULL,
	[CD_CARAC_ESPEC] [varchar](2) NULL,
	[CD_CLASS_RISCO_OP] [varchar](2) NULL,
	[FL_COOBRIGACAO] [bit] NULL,
	[CD_TP_PESSOA] [varchar](1) NULL,
	[CD_CLASS_RISCO_CLI] [varchar](2) NULL,
	[VL_PERC_COOBRIGACAO] [numeric](10, 7) NULL,
	[VL_PERC_SUBORDINACAO] [numeric](10, 7) NULL,
	[CD_DESEMPENHO] [varchar](2) NULL,
	[CD_TP_CONTROLE] [varchar](2) NULL,
 CONSTRAINT [PK__ARQUIVO_DP_FLUXO] PRIMARY KEY CLUSTERED 
(
	[ID_ARQUIVO_FLUXO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_ARQUIVO_DP_FLUXO]  WITH CHECK ADD  CONSTRAINT [FK__ARQUIVO_DP_FLUXO__ARQUIVO_DP] FOREIGN KEY([ID_ARQUIVO])
REFERENCES [dbo].[TB_3040_ARQUIVO_DP] ([ID_ARQUIVO])
ON DELETE CASCADE
ALTER TABLE [dbo].[TB_3040_ARQUIVO_DP_FLUXO] CHECK CONSTRAINT [FK__ARQUIVO_DP_FLUXO__ARQUIVO_DP]