{#
  This macro takes an input column containing number of seconds,
  and returns the sql for converting it to a time type.

  Negative values are set to null.

  Decimal values are not supported, and will cause an error
  (provide "col_name::int" as arg to ignore decimal portion).

  Values >= 24 hours are not supported, and will cause the value to be set to null.
  This is because the conversion will truncate the days portion, meaning that 25 hours
  will be converted to 01:00:00.
#}
{% macro convert_seconds_to_time_type(input_column) %}
  case
    when {{ input_column }} < 0 or {{ input_column }} >= 86400 then null
    else to_time({{ input_column }}::varchar)
  end
{% endmacro %}
