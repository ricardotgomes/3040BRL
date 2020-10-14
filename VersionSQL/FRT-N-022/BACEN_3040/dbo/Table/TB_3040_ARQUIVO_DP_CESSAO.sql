/****** Object:  Table [dbo].[TB_3040_ARQUIVO_DP_CESSAO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_ARQUIVO_DP_CESSAO](
	[ID_ARQUIVO_CESSAO] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_ARQUIVO] [int] NOT NULL,
	[CD_CONTRATO_CEDENTE] [varchar](100) NOT NULL,
	[CD_SISTEMA_ORIGEM] [varchar](3) NOT NULL,
	[TP_ATIVO] [varchar](40) NOT NULL,
	[DT_AQUISICAO] [date] NOT NULL,
	[DOC_ORIGINADOR] [varchar](14) NULL,
	[FL_COOBRIGACAO] [bit] NOT NULL,
	[TX_OPERACAO] [numeric](25, 10) NOT NULL,
	[VL_CONTRATO] [numeric](19, 4) NOT NULL,
	[VL_NOMINAL] [numeric](19, 4) NOT NULL,
	[VL_PERC_COOBRIGACAO] [numeric](10, 7) NULL,
	[VL_PERC_SUBORDINACAO] [numeric](10, 7) NULL,
	[VL_PDD] [numeric](19, 4) NOT NULL,
	[DOC_CEDENTE] [varchar](14) NOT NULL,
 CONSTRAINT [PK__ARQUIVO_DP_CESSAO] PRIMARY KEY CLUSTERED 
(
	[ID_ARQUIVO_CESSAO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_ARQUIVO_DP_CESSAO]  WITH CHECK ADD  CONSTRAINT [FK__ARQUIVO_DP_CESSAO__ARQUIVO_DP] FOREIGN KEY([ID_ARQUIVO])
REFERENCES [dbo].[TB_3040_ARQUIVO_DP] ([ID_ARQUIVO])
ON DELETE CASCADE
ALTER TABLE [dbo].[TB_3040_ARQUIVO_DP_CESSAO] CHECK CONSTRAINT [FK__ARQUIVO_DP_CESSAO__ARQUIVO_DP]