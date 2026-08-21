-- Loan/installment tracking now lives in bank_accounts + personal_debts,
-- not expense_categories. Stop seeding "Vay/Trả góp" for newly created homes.
-- Existing homes keep their historical category rows.

create or replace function public.seed_default_expense_categories()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.expense_categories (home_id, name, icon_key, color_key, is_default)
  values
    (new.id, 'Ăn uống/Chợ', 'restaurant', 'food', true),
    (new.id, 'Bảo hiểm/Y tế', 'health_and_safety', 'health', true),
    (new.id, 'Học phí con', 'school', 'tuition', true),
    (new.id, 'Khác', 'more_horiz', 'other', true);
  return new;
end;
$$;
