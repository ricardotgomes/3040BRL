/****** Object:  Table [dbo].[TB_BATCH_STATUS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_BATCH_STATUS](
	[ID_BATCH_STATUS] [bigint] IDENTITY(1,1) NOT NULL,
	[DT_REFER] [date] NOT NULL,
	[FIM_PROC] [datetime2](7) NULL,
	[INICIO_PROC] [datetime2](7) NOT NULL,
	[DS_MENSAGEM] [varchar](1000) NULL,
	[NOME_FUNDO] [varchar](1000) NULL,
	[NM_PROCESSO] [varchar](100) NULL,
	[STATUS] [varchar](25) NULL,
	[USUARIO] [varchar](50) NULL,
 CONSTRAINT [PK__BATCH_STATUS] PRIMARY KEY CLUSTERED 
(
	[ID_BATCH_STATUS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]