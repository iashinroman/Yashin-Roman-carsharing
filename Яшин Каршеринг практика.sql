USE Carsharing;
GO


SELECT 
    c.client_id,
    c.full_name AS client_name,
    b.booking_id,
    b.start_time,
    b.end_time,
    
    -- Ðàñ÷¸ò äëèòåëüíîñòè â ìèíóòàõ
    DATEDIFF(MINUTE, b.start_time, ISNULL(b.end_time, GETDATE())) AS duration_minutes,
    
    -- Ðàñ÷¸ò ïðîéäåííîãî ðàññòîÿíèÿ (êì)
    ISNULL(b.end_mileage, cr.current_mileage_km) - b.start_mileage AS distance_km,
    
    -- Áàçîâûé òàðèô çà ìèíóòó
    t.price_per_minute AS tariff_per_minute,
    
    -- Òàðèô çà êì (ñâåðõ âêëþ÷åííûõ)
    t.price_per_km AS tariff_per_km,
    
    -- Âêëþ÷åííûå êèëîìåòðû çà âðåìÿ ïîåçäêè
    DATEDIFF(HOUR, b.start_time, ISNULL(b.end_time, GETDATE())) * t.included_km_per_hour AS included_km_total,
    
    -- Ðàñ÷åò ñòîèìîñòè:
    ROUND(
        (DATEDIFF(MINUTE, b.start_time, ISNULL(b.end_time, GETDATE())) * t.price_per_minute)
        +
        (CASE 
            WHEN (ISNULL(b.end_mileage, cr.current_mileage_km) - b.start_mileage) - 
                 (DATEDIFF(HOUR, b.start_time, ISNULL(b.end_time, GETDATE())) * t.included_km_per_hour) > 0
            THEN ((ISNULL(b.end_mileage, cr.current_mileage_km) - b.start_mileage) - 
                  (DATEDIFF(HOUR, b.start_time, ISNULL(b.end_time, GETDATE())) * t.included_km_per_hour)) 
                 * t.price_per_km
            ELSE 0
        END),
        2
    ) AS calculated_cost,
    
    -- Äàííûå îá àâòî
    m.brand,
    m.model_name,
    cr.license_plate,
    b.booking_status

FROM 
    Bookings b
    JOIN Clients c ON b.client_id = c.client_id
    JOIN Cars cr ON b.car_id = cr.car_id
    JOIN Models m ON cr.model_id = m.model_id
    JOIN Tariffs t ON m.tariff_id = t.tariff_id

WHERE 
    b.booking_status IN ('Completed', 'Active')
    
ORDER BY 
    b.start_time DESC;
GO
