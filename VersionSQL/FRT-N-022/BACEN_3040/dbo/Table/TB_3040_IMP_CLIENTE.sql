/****** Object:  Table [dbo].[TB_3040_IMP_CLIENTE]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_IMP_CLIENTE](
	[ID_3040_IMP_CLIENTE] [bigint] IDENTITY(1,1) NOT NULL,
	[TP_CLIENTE] [varchar](31) NOT NULL,
	[CEP] [varchar](8) NULL,
	[CONG_ECONOMICO] [varchar](40) NULL,
	[VL_FAT_ANUAL] [numeric](19, 2) NULL,
	[DT_INI_RELAC] [date] NULL,
	[CD_LOCALIZACAO] [varchar](255) NULL,
	[CD_TP_CONTROLE] [varchar](255) NULL,
	[CD_TP_PESSOA] [varchar](255) NULL,
	[CD_RATING] [varchar](255) NULL,
	[CD_AUTORIZACAO] [varchar](255) NULL,
	[CD_PORTE_PJ] [varchar](255) NULL,
	[CD_PORTE_PF] [varchar](255) NULL,
	[DOC_CLIENTE] [varchar](14) NOT NULL,
	[NM_CLIENTE] [varchar](100) NOT NULL,
	[IS_SFN] [bit] NULL,
	[CD_SISTEMA_ORIGEM] [varchar](10) NULL
) ON [PRIMARY]