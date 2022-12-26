with prod as (
select
ct.category_name, sp.company_name suppliers, pd.product_name, pd.unit_price, pd.product_id
from {{source('sources', 'products')}} pd
left join {{source('sources', 'suppliers')}} sp on (sp.supplier_id = pd.supplier_id)
left join {{source('sources', 'categories')}} ct on (ct.category_id = pd.category_id)
), orddetai as (
    select pd.*, od.order_id, od.quantity, od.discount
    from {{ref('orderdetails')}} od
    left join prod pd on (pd.product_id = od.product_id)
), ordrs as (
select ord.order_date, ord.order_id, cs.company_name customer, em.name employee, em.age, em.lengthofservice
from {{source('sources', 'orders')}} ord   
left join {{ref('customers')}} cs on (ord.customer_id = cs.customer_id)
left join {{ref('employees')}} em on (em.employee_id = ord.employee_id)
left join {{source('sources', 'shippers')}} sh on (ord.ship_via = sh.shipper_id)
) , finaljoin as (
select od.*, ord.order_date, ord.customer, ord.employee, ord.age, ord.lengthofservice
from orddetai od
inner join ordrs ord on (ord.order_id = od.order_id)
)

select * from finaljoin