/****** Object:  Table [dbo].[TB_3040_ANEXO_20_AUTORIZACAO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_ANEXO_20_AUTORIZACAO](
	[ID_ANEXO_20] [int] IDENTITY(1,1) NOT NULL,
	[CD_AUTORIZACAO] [varchar](1) NOT NULL,
	[DS_AUTORIZACAO] [varchar](25) NOT NULL,
	[IS_ATIVO] [bit] NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__ANEXO_20] PRIMARY KEY CLUSTERED 
(
	[ID_ANEXO_20] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]