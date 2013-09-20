class CreateCharityTotals < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW charity_totals AS
        SELECT
          backers.charity_id,
          sum(backers.value) AS pledged,
          sum(backers.payment_service_fee) AS total_payment_service_fee,
          count(*) AS total_backers
        FROM backers
        WHERE (backers.state in ('confirmed', 'refunded', 'requested_refund'))
        GROUP BY backers.charity_id;
    SQL
  end
  
  def down
    execute <<-SQL
      DROP VIEW charity_totals;
    SQL
  end
end
