
data "external" "get_product_id" {
  program = ["bash", "../scripts/getPortfolioId.sh"]
}

data "aws_servicecatalog_portfolio" "control_tower_portfolio" {
  id = data.external.get_product_id.result.Id
}

resource "aws_servicecatalog_principal_portfolio_association" "cicd_role_sc_principal" {
  portfolio_id  = data.aws_servicecatalog_portfolio.control_tower_portfolio.id
  principal_arn = aws_iam_role.cicd_role.arn
}
