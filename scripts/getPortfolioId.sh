#!/bin/bash
set -e
aws servicecatalog list-portfolios --query "PortfolioDetails[?DisplayName=='AWS Control Tower Account Factory Portfolio']" | jq first
