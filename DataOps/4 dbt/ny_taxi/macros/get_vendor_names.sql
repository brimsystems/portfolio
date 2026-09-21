{% macro get_vendor_names(vendor_id) -%}

case 
    when {{vendor_id}} = 1 then 'Vendor 1' 
    when {{vendor_id}} = 2 then 'Vendor 2'
    when {{vendor_id}} = 4 then 'Vendor 4'
    else 'Unknown'
end 

{%- endmacro %}