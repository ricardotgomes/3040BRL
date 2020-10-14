/****** Object:  Table [dbo].[TB_3040_IMP_LOG]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_IMP_LOG](
	[ID_FUNDO] [int] NOT NULL,
	[QT_IMP_OP] [int] NOT NULL,
	[TM_IMP_OP] [varchar](12) NOT NULL,
	[QT_IMP_CLI] [int] NOT NULL,
	[TM_IMP_CLI] [varchar](12) NOT NULL,
	[QT_DP_OP] [int] NULL,
	[M_DP_OP] [varchar](12) NULL,
	[QT_DP_CLI] [int] NULL,
	[TM_DP_CLI] [varchar](12) NULL,
	[TM_TOTAL] [varchar](12) NOT NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_3040_IMP_LOG]  WITH CHECK ADD  CONSTRAINT [FK__IMP_LOG__FUNDO] FOREIGN KEY([ID_FUNDO])
REFERENCES [dbo].[TB_3040_BAS_FUNDO] ([ID_FUNDO])
ON DELETE CASCADE
ALTER TABLE [dbo].[TB_3040_IMP_LOG] CHECK CONSTRAINT [FK__IMP_LOG__FUNDO]