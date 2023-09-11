{%- macro source_and_id_based_key(source_name, id_colname) -%}
  {#-
      Generate a surrogate key by hashing a source name together with the id col.
      If the id col is null, the key will be null.
  -#}

  {%- set source_str = "lower('" ~ source_name ~ "')" -%}
  {%- set id_str = "cast(" ~ id_colname ~ " as " ~ dbt.type_string() ~ ")" -%}

  {{
    "case when " ~ id_colname ~ " is null then null
      else " ~ dbt.hash(dbt.concat([source_str, "'-'", id_str])) ~ "
    end"
  }}

{%- endmacro -%}
