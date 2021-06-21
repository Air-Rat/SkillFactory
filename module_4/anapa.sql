WITH t_planes AS
    (-- Информация о самолётах
    WITH class_b AS
        (
        SELECT a.aircraft_code,
               a.model, 
               a.range,
               count(s.fare_conditions) fare_conditions_b
            FROM dst_project.aircrafts a
                JOIN dst_project.seats s ON a.aircraft_code = s.aircraft_code
            WHERE s.fare_conditions = 'Business'
            GROUP BY 1, 2, 3
        ),
        
        class_c AS
        (
        SELECT a.aircraft_code,
               a.model, 
               a.range,
               count(s.fare_conditions) fare_conditions_c
            FROM dst_project.aircrafts a
                JOIN dst_project.seats s ON a.aircraft_code = s.aircraft_code
            WHERE s.fare_conditions = 'Comfort'
            GROUP BY 1, 2, 3
        ),

        class_e AS
        (
        SELECT a.aircraft_code,
               a.model, 
               a.range,
               count(s.fare_conditions) fare_conditions_e
            FROM dst_project.aircrafts a
                JOIN dst_project.seats s ON a.aircraft_code = s.aircraft_code
            WHERE s.fare_conditions = 'Economy'
            GROUP BY 1, 2, 3
        )

    SELECT class_e.aircraft_code,
           class_e.model, 
           class_e.range,
           fare_conditions_b,
           fare_conditions_c,
           fare_conditions_e
        FROM class_b
        FULL OUTER JOIN class_c ON class_b.aircraft_code = class_c.aircraft_code
        FULL OUTER JOIN class_e ON class_b.aircraft_code = class_e.aircraft_code
    ),
    
    t_airflights AS
    (-- Информация о полётах
    SELECT f.*, a.*
        FROM dst_project.flights f
            JOIN dst_project.airports a ON a.airport_code = f.arrival_airport
    ),
    
    t_amounts AS    
    (-- Информация о перелётах и стоимости проданных билетов
    WITH class_b AS
        (
        SELECT tf.flight_id, 
               count(tf.fare_conditions) total_tickets_b,
               sum(tf.amount) total_amount_b
            FROM dst_project.tickets t
                JOIN dst_project.ticket_flights tf ON tf.ticket_no = t.ticket_no
            WHERE tf.fare_conditions = 'Business'
            GROUP BY tf.flight_id
        ),
        
        class_c AS
        (
        SELECT tf.flight_id, 
               count(tf.fare_conditions) total_tickets_c,
               sum(tf.amount) total_amount_c
            FROM dst_project.tickets t
                JOIN dst_project.ticket_flights tf ON tf.ticket_no = t.ticket_no
            WHERE tf.fare_conditions = 'Comfort'
            GROUP BY tf.flight_id
        ),
        
        class_e AS
        (
        SELECT tf.flight_id, 
               count(tf.fare_conditions) total_tickets_e,
               sum(tf.amount) total_amount_e
            FROM dst_project.tickets t
                JOIN dst_project.ticket_flights tf ON tf.ticket_no = t.ticket_no
            WHERE tf.fare_conditions = 'Economy'
            GROUP BY tf.flight_id
        )

    SELECT class_e.flight_id,
           total_tickets_b,
           total_amount_b,
           total_tickets_c,
           total_amount_c,
           total_tickets_e,
           total_amount_e
        FROM class_b
        FULL OUTER JOIN class_c ON class_b.flight_id = class_c.flight_id
        FULL OUTER JOIN class_e ON class_b.flight_id = class_e.flight_id
    )    
    
SELECT f.flight_id,
       f.flight_no,
       f.scheduled_departure,
       f.scheduled_arrival,
       f.status,
       f.actual_departure,
       f.actual_arrival,
       extract(epoch FROM age(f.actual_arrival, f.actual_departure))/60 duration,
       f.airport_code,
       f.airport_name,
       f.city,
       f.longitude,
       f.latitude,
       p.aircraft_code,
       p.model,
       p.range,
       p.fare_conditions_b,
       p.fare_conditions_c,
       p.fare_conditions_e,
       a.total_tickets_b,
       a.total_amount_b,
       a.total_tickets_c,
       a.total_amount_c,
       a.total_tickets_e,
       a.total_amount_e
FROM t_airflights f
    LEFT JOIN t_planes p ON p.aircraft_code = f.aircraft_code
    LEFT JOIN t_amounts a ON a.flight_id = f.flight_id
WHERE departure_airport = 'AAQ'
  AND (date_trunc('month', scheduled_departure) in ('2017-01-01', '2017-02-01', '2016-12-01'))
  AND status not in ('Cancelled')