-- Seed finance demo data for the home named "Testing".
-- Run in Supabase SQL Editor (bypasses RLS). Safe to re-run: replaces
-- bank credit / personal debts / savings for that home only.
-- Does not touch electricity / water / expenses / incomes.

do $$
declare
  v_home public.homes%rowtype;
  v_owner uuid;
  v_month date := date_trunc('month', current_date)::date;
  v_prev_month date := (date_trunc('month', current_date) - interval '1 month')::date;
  v_acc_vcb uuid;
  v_acc_tcb uuid;
  v_debt_owe uuid;
  v_debt_owed uuid;
  v_debt_settled uuid;
  v_sav_term uuid;
  v_sav_goal uuid;
begin
  select * into strict v_home
  from public.homes
  where name = 'Testing';

  select user_id into strict v_owner
  from public.home_members
  where home_id = v_home.id and role = 'owner';

  -- Cascade clears periods / payments / contributions.
  delete from public.bank_accounts where home_id = v_home.id;
  delete from public.personal_debts where home_id = v_home.id;
  delete from public.savings where home_id = v_home.id;

  raise notice 'Seeding finance for home % (%) owner=%',
    v_home.name, v_home.id, v_owner;

  -- —— Bank credit ——
  insert into public.bank_accounts (
    home_id, bank_name, credit_limit, statement_day, due_day, note
  ) values (
    v_home.id, 'Vietcombank', 50000000, 15, 5, 'seed thẻ chính'
  )
  returning id into v_acc_vcb;

  insert into public.bank_accounts (
    home_id, bank_name, credit_limit, statement_day, due_day, note
  ) values (
    v_home.id, 'Techcombank', 30000000, 20, 10, 'seed thẻ phụ'
  )
  returning id into v_acc_tcb;

  insert into public.bank_account_periods (
    bank_account_id, period_month, balance_used, payment_due, payment_made,
    is_paid, note
  ) values
    (
      v_acc_vcb, v_prev_month, 12000000, 3500000, 3500000,
      true, 'seed kỳ trước'
    ),
    (
      v_acc_vcb, v_month, 18500000, 4200000, 0,
      false, 'seed kỳ hiện tại'
    ),
    (
      v_acc_tcb, v_month, 6200000, 1500000, 500000,
      false, 'seed kỳ hiện tại'
    );

  -- —— Personal debts ——
  insert into public.personal_debts (
    home_id, direction, counterparty_name, principal_amount, remaining_amount,
    due_date, interest_rate, is_settled, note, created_by
  ) values (
    v_home.id, 'i_owe', 'Anh Minh', 10000000, 6500000,
    (current_date + 45)::date, null, false, 'seed vay cá nhân', v_owner
  )
  returning id into v_debt_owe;

  insert into public.personal_debt_payments (
    debt_id, amount, paid_date, note
  ) values
    (v_debt_owe, 2000000, (current_date - 30)::date, 'seed trả đợt 1'),
    (v_debt_owe, 1500000, (current_date - 10)::date, 'seed trả đợt 2');

  insert into public.personal_debts (
    home_id, direction, counterparty_name, principal_amount, remaining_amount,
    due_date, interest_rate, is_settled, note, created_by
  ) values (
    v_home.id, 'owed_to_me', 'Chị Lan', 5000000, 3000000,
    (current_date + 20)::date, null, false, 'seed cho mượn', v_owner
  )
  returning id into v_debt_owed;

  insert into public.personal_debt_payments (
    debt_id, amount, paid_date, note
  ) values (
    v_debt_owed, 2000000, (current_date - 7)::date, 'seed nhận trả'
  );

  insert into public.personal_debts (
    home_id, direction, counterparty_name, principal_amount, remaining_amount,
    due_date, interest_rate, is_settled, note, created_by
  ) values (
    v_home.id, 'i_owe', 'Bạn Hùng', 2000000, 0,
    (current_date - 5)::date, null, true, 'seed đã tất toán', v_owner
  )
  returning id into v_debt_settled;

  insert into public.personal_debt_payments (
    debt_id, amount, paid_date, note
  ) values (
    v_debt_settled, 2000000, (current_date - 5)::date, 'seed tất toán'
  );

  -- —— Savings ——
  insert into public.savings (
    home_id, type, name, bank_name, interest_rate, term_months,
    maturity_date, target_amount, current_amount, note
  ) values (
    v_home.id, 'term_deposit', 'Sổ tiết kiệm 6 tháng', 'Vietcombank',
    5.5, 6, (current_date + 120)::date, null, 50000000, 'seed gửi kỳ hạn'
  )
  returning id into v_sav_term;

  insert into public.savings_contributions (
    savings_id, amount, contributed_date, note
  ) values (
    v_sav_term, 50000000, (current_date - 60)::date, 'seed gửi ban đầu'
  );

  insert into public.savings (
    home_id, type, name, bank_name, interest_rate, term_months,
    maturity_date, target_amount, current_amount, note
  ) values (
    v_home.id, 'goal', 'Quỹ du lịch Đà Nẵng', null,
    null, null, null, 20000000, 8500000, 'seed mục tiêu'
  )
  returning id into v_sav_goal;

  insert into public.savings_contributions (
    savings_id, amount, contributed_date, note
  ) values
    (v_sav_goal, 5000000, (current_date - 40)::date, 'seed góp 1'),
    (v_sav_goal, 3500000, (current_date - 15)::date, 'seed góp 2');
end $$;

select
  h.name,
  (select count(*) from public.bank_accounts b where b.home_id = h.id) as bank_accounts,
  (select count(*) from public.bank_account_periods p
     join public.bank_accounts b on b.id = p.bank_account_id
    where b.home_id = h.id) as bank_periods,
  (select count(*) from public.personal_debts d where d.home_id = h.id) as debts,
  (select count(*) from public.personal_debt_payments pay
     join public.personal_debts d on d.id = pay.debt_id
    where d.home_id = h.id) as debt_payments,
  (select count(*) from public.savings s where s.home_id = h.id) as savings,
  (select count(*) from public.savings_contributions c
     join public.savings s on s.id = c.savings_id
    where s.home_id = h.id) as contributions
from public.homes h
where h.name = 'Testing';
