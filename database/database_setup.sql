--===================================
-- SECTION 2: DML QUERIES 
--===================================
--This section adds sample data to the tables built in section 1
--The values are made up but the SMS bodies follow the real MTN MOMO Rwanda messages
--Format used was taken from the project's XML file
--phone numbers follow the Rwandan format
--All money amounts are in RWF
--Rows are inserted following an order where parent rows are inserted first, then children rows, so no foreign key breaks 
--===================================


-- ======USERS Table (5 rows)======
-- Five end users with MOMO accounts. These are people sending and receiving money
INSERT INTO users (user_id, full_name, created_at) VALUES
(1, 'UWASE Yvette', '2026-05-13 10:00:00'),
(2, 'UWAMAHORO Josiane', '2026-05-14 10:05:00'),
(3, 'MUKASE Claudine', '2026-05-15 10:30:00'),
(4, 'HABIMANA Jean', '2026-05-16 11:45:00'),
(5, 'KAYIRANGA Marie', '2026-05-17 13:50:00');

-- =======AGENTS Table (5 rows)======
-- Five MOMO agents. Users visit them inorder to deposit and withdraw cash
-- Names follow MTN Agents naming style used in the XML file(e.g "Agent Sophia")
INSERT INTO agents (agent_id, agent_name, agent_code, created_at) VALUES
(1, 'Agent Eric' , 'AGT-001', '2026-05-10 08:02:00'),
(2, 'Agent Sarah', 'AGT-002', '2026-05-10 08:50:00'),
(3, 'Agent Davis', 'AGT-003', '2026-05-11 08:30:00'),
(4, 'Agent Katrina', 'AGT-004', '2026-05-11 09:00:00'),
(5, 'Agent Fabiola', 'AGT-005', '2026-05-11 09:35:00');

-- ========MERCHANTS Table (5 rows)======
-- 







