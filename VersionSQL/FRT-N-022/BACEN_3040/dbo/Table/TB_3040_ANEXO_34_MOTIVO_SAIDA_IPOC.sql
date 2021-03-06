/****** Object:  Table [dbo].[TB_3040_ANEXO_34_MOTIVO_SAIDA_IPOC]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_ANEXO_34_MOTIVO_SAIDA_IPOC](
	[ID_ANEXO_34] [int] IDENTITY(1,1) NOT NULL,
	[CD_MOTIVO_SAIDA_IPOC] [varchar](2) NOT NULL,
	[DS_MOTIVO_SAIDA_IPOC] [varchar](150) NOT NULL,
	[IS_ATIVO] [bit] NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__ANEXO_34] PRIMARY KEY CLUSTERED 
(
	[ID_ANEXO_34] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]