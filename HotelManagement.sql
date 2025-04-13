-- Create the database for the Movie Rental System
CREATE DATABASE HotelBookingDB;
USE HotelBookingDB;

-- Create the Rooms table
CREATE TABLE Rooms (
    room_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- Unique room identifier
    room_type VARCHAR(50) NOT NULL,          -- Type of room
    price DECIMAL(10, 2) NOT NULL,           -- Price per night
    is_available BOOLEAN DEFAULT TRUE        -- Room availability status
);

-- Insert rooms into Rooms table
INSERT INTO Rooms (room_type, price) VALUES
('Single', 100.00),
('Double', 150.00),
('Suite', 300.00);

-- Create the Guests table
CREATE TABLE Guests (
    guest_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each guest
    name VARCHAR(25) NOT NULL,               -- Full name of the guest
    email VARCHAR(25) UNIQUE,                -- Email address (must be unique)
    phone VARCHAR(15),                        -- Contact number
    join_date DATE DEFAULT (CURRENT_DATE)     -- Guest join date
);

-- Insert guests into Guests table
INSERT INTO Guests (name, email, phone) VALUES
('Paul Adam', 'pauladam@example.com', '1234567890'),
('Devon McGraw', 'devonmcgraw@example.com', '0987654321');


-- Create the Bookings table
CREATE TABLE Bookings (
    booking_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,   -- Unique identifier for each booking
    guest_id INT,                                -- Foreign key to Guests table
    room_id INT,                                 -- Foreign key to Rooms table
    check_in DATE NOT NULL,                      -- Check-in date
    check_out DATE NOT NULL,                     -- Check-out date
    total_amount DECIMAL(10, 2) NOT NULL,        -- Total amount for the booking
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id), -- Linking to Guests
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)     -- Linking to Rooms
);

-- Insert booking records into Bookings table
INSERT INTO Bookings (guest_id, room_id, check_in, check_out, total_amount) VALUES
(1, 1, '2024-11-01', '2024-11-05', 400.00),
(2, 2, '2024-11-10', '2024-11-15', 750.00);


-- Create the Payments table
CREATE TABLE Payments (
    payment_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each payment
    booking_id INT,                             -- Foreign key to Bookings table
    amount_paid DECIMAL(10, 2) NOT NULL,        -- Amount paid
    payment_date DATE DEFAULT (CURRENT_DATE),   -- Payment date
    payment_status ENUM('Paid', 'Unpaid') DEFAULT 'Unpaid', -- Payment status
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) -- Link to Bookings
);



-- Insert payments into Payments table
INSERT INTO Payments (booking_id, amount_paid, payment_status) VALUES
(1, 400.00, 'Paid'),
(2, 750.00, 'Paid');


-- Create the Staff table
CREATE TABLE Staff (
    staff_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each staff member
    name VARCHAR(25) NOT NULL,               -- Full name of the staff member
    role VARCHAR(100)                         -- Role of the staff member
);

-- Insert staff into Staff table
INSERT INTO Staff (name, role) VALUES
('Stain Hill', 'Manager'),
('Steave Harris', 'Receptionist');

--Query-1: List Available Rooms
SELECT *                 
FROM Rooms                
WHERE is_available = TRUE;

--Query-2: Get Booking Details for a Guest
SELECT *                   
FROM Bookings              
WHERE guest_id = 1;

--Query-3: Total Revenue from Bookings
SELECT SUM(total_amount) AS total_revenue 
FROM Bookings;

--Query-4: Room Occupancy Report
SELECT room_type,     
COUNT(*) AS occupancy_count     
FROM Bookings                          
JOIN Rooms ON Bookings.room_id = Rooms.room_id 
GROUP BY room_type;  

--Query-5: Payment Status by Booking
SELECT b.booking_id,                  
       b.total_amount,                
       p.amount_paid,                 
       p.payment_status               
FROM Bookings b                       
LEFT JOIN Payments p ON b.booking_id = p.booking_id;  

--Query-6: Calculate Occupancy Rate for Each Room Type
SELECT r.room_type,                           
COUNT(b.booking_id) AS total_bookings, 
(COUNT(b.booking_id) / (DATEDIFF(CURDATE(), MIN(b.check_in)))) * 100 AS occupancy_rate
FROM Rooms r                                  
LEFT JOIN Bookings b ON r.room_id = b.room_id 
GROUP BY r.room_type;  

--Query-7: Find All Guests with Multiple Bookings
SELECT g.guest_id,                     
g.name,COUNT(b.booking_id) AS booking_count 
FROM Guests g                          
JOIN Bookings b ON g.guest_id = b.guest_id 
GROUP BY g.guest_id                    
HAVING booking_count > 1; 

--Query-8: Calculate Average Booking Duration by Room Type
SELECT r.room_type,                              
AVG(DATEDIFF(b.check_out, b.check_in)) AS avg_duration 
FROM Rooms r                                     
JOIN Bookings b ON r.room_id = b.room_id         
GROUP BY r.room_type;   

--Query-9: Total Revenue per Room Type
SELECT r.room_type,                                 
SUM(b.total_amount) AS total_revenue         
FROM Rooms r                                        
JOIN Bookings b ON r.room_id = b.room_id            
GROUP BY r.room_type;

--Query-10: List All Overdue Check-Outs (Where Check-Out Date is Past and Room is Still Marked as Booked)
SELECT b.booking_id,                          
g.name,b.check_out,r.room_type                             
FROM Bookings b                                
JOIN Guests g ON b.guest_id = g.guest_id       
JOIN Rooms r ON b.room_id = r.room_id          
WHERE b.check_out < CURDATE()                  
AND r.is_available = FALSE;    

--Query-11: Identify High-Spending Guests (Guests Who Have Spent More Than a Given Amount)
SELECT g.guest_id,                         
       g.name,                             
       SUM(b.total_amount) AS total_spent 
FROM Guests g                             
JOIN Bookings b ON g.guest_id = b.guest_id 
GROUP BY g.guest_id                       
HAVING total_spent > 1000;                


--Query-12: Get Upcoming Check-Ins for the Next 7 Days
SELECT b.booking_id,               
g.name,                     
       b.check_in,                
       r.room_type                
FROM Bookings b                   
JOIN Guests g ON b.guest_id = g.guest_id 
JOIN Rooms r ON b.room_id = r.room_id    
WHERE b.check_in BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY); 


--Query-13: Generate Monthly Revenue Report for the Current Year
SELECT MONTH(b.check_in) AS month,           
       SUM(b.total_amount) AS monthly_revenue 
FROM Bookings b                               
WHERE YEAR(b.check_in) = YEAR(CURDATE())      
GROUP BY month                                
ORDER BY month;                               


--Query-14: List Rooms that Have Not Been Booked in the Past 6 Months
SELECT r.room_id, r.room_type                  
FROM Rooms r                                   
LEFT JOIN Bookings b ON r.room_id = b.room_id  
     AND b.check_in >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) 
WHERE b.booking_id IS NULL;                    


--Query-15: Find Most Popular Room Type Based on Bookings
SELECT room_type, COUNT(*) AS bookings_count  
FROM Bookings b                               
JOIN Rooms r ON b.room_id = r.room_id         
GROUP BY r.room_type                          
ORDER BY bookings_count DESC                  
LIMIT 1;                                      


--Query-16: Calculate Total Unpaid Amounts by Booking ID
SELECT b.booking_id,  
       (b.total_amount - COALESCE(SUM(p.amount_paid), 0)) AS unpaid_amount  
FROM Bookings b 
LEFT JOIN Payments p ON b.booking_id = p.booking_id  
GROUP BY b.booking_id  
HAVING unpaid_amount > 0;  


--Query-17: Identify Top 5 Guests by Spending
SELECT g.guest_id,  
       g.name,  
       SUM(b.total_amount) AS total_spent  
FROM Guests g  
JOIN Bookings b ON g.guest_id = b.guest_id  
GROUP BY g.guest_id  
ORDER BY total_spent DESC  
LIMIT 5;  


--Query-18: Calculate Room Occupancy for Each Month
SELECT MONTH(b.check_in) AS month,  
r.room_type,  
       COUNT(b.booking_id) AS occupied_days  
FROM Bookings b  
JOIN Rooms r ON b.room_id = r.room_id  
GROUP BY month, r.room_type  
ORDER BY month;  

--Query-19: Find All Payments with Late Payments Status (Payments Made After Check-Out)
SELECT p.payment_id,  
       b.booking_id,  
       g.name,  
       p.payment_date,  
       b.check_out 
FROM Payments p  
JOIN Bookings b ON p.booking_id = b.booking_id  
JOIN Guests g ON b.guest_id = g.guest_id  
WHERE p.payment_date > b.check_out;  






