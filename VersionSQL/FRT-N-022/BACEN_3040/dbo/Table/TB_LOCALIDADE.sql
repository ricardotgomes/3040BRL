/****** Object:  Table [dbo].[TB_LOCALIDADE]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_LOCALIDADE](
	[CODIGO] [varchar](10) NOT NULL,
	[DESCRICAO] [varchar](255) NULL,
	[ID_LOCALIDADE] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_LOCALIDADE] PRIMARY KEY CLUSTERED 
(
	[ID_LOCALIDADE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]