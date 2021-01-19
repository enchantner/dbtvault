from behave import *

from test_project.test_utils.dbt_test_utils import DBTVAULTGenerator

use_step_matcher("parse")

dbtvault_generator = DBTVAULTGenerator()


@step("I insert by rank into the {model_name} {vault_structure} with a {rank_column} rank column")
def rank_insert(context, model_name, vault_structure, rank_column):
    metadata = {"source_model": context.processed_stage_name,
                **context.vault_structure_columns[model_name]}

    config = {"materialized": "vault_insert_by_rank",
              "rank_column": rank_column,
              "rank_source_models": context.processed_stage_name}

    context.vault_structure_metadata = metadata

    dbtvault_generator.raw_vault_structure(model_name=model_name,
                                           vault_structure=vault_structure,
                                           config=config,
                                           **metadata)

    is_full_refresh = context.dbt_test_utils.check_full_refresh(context)

    logs = context.dbt_test_utils.run_dbt_model(mode="run", model_name=model_name,
                                                full_refresh=is_full_refresh)

    assert "Completed successfully" in logs


@step("I insert by rank into the {model_name} {vault_structure}")
def rank_insert(context, model_name, vault_structure):
    metadata = {"source_model": context.processed_stage_name,
                **context.vault_structure_columns[model_name]}

    rank_column = context.rank_column

    config = {"materialized": "vault_insert_by_rank",
              "rank_column": rank_column,
              "rank_source_models": context.processed_stage_name}

    context.vault_structure_metadata = metadata

    dbtvault_generator.raw_vault_structure(model_name=model_name,
                                           vault_structure=vault_structure,
                                           config=config,
                                           **metadata)

    is_full_refresh = context.dbt_test_utils.check_full_refresh(context)

    logs = context.dbt_test_utils.run_dbt_model(mode="run", model_name=model_name,
                                                full_refresh=is_full_refresh)

    assert "Completed successfully" in logs


@step("I have a rank column {rank_column} in the {stage_name} stage partitioned by {"
      "partitioned_by_column} and ordered by {ordered_by_column}")
def define_rank_column(context, rank_column, stage_name, partitioned_by_column, ordered_by_column):

    if hasattr(context, 'derived_columns'):

        context.derived_columns[stage_name] = ({**context.derived_columns[stage_name],
                                                rank_column: f"RANK() OVER (PARTITION BY {partitioned_by_column} "
                                                             f"ORDER BY {ordered_by_column})"})

    else:

        context.derived_columns = {stage_name: {rank_column: f"RANK() OVER (PARTITION BY {partitioned_by_column} "
                                                             f"ORDER BY {ordered_by_column})"}}

    context.rank_column = rank_column
