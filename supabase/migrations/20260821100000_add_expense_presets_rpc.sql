-- Frequent expense presets for quick-add chips (last 60 days, rounded to 5.000đ).

create or replace function public.get_frequent_expense_presets(
  p_home_id uuid,
  p_limit int default 6
)
returns table (
  category_id uuid,
  category_name text,
  rounded_amount numeric,
  occurrence_count bigint
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_home_member(p_home_id) then
    raise exception 'not a home member';
  end if;

  return query
  select
    e.category_id,
    c.name as category_name,
    (round(e.amount_vnd / 5000.0) * 5000)::numeric as rounded_amount,
    count(*)::bigint as occurrence_count
  from public.expenses e
  join public.expense_categories c on c.id = e.category_id
  where e.home_id = p_home_id
    and e.expense_date >= (current_date - interval '60 days')
  group by e.category_id, c.name, round(e.amount_vnd / 5000.0) * 5000
  order by occurrence_count desc
  limit greatest(coalesce(p_limit, 6), 1);
end;
$$;

grant execute on function public.get_frequent_expense_presets(uuid, int)
  to authenticated;
