using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;

namespace SmartParking.Infrastructure.Data;

public static class DbInitializer
{
    public static void Seed(AppDbContext context)
    {
        // Prevent duplicate seeding
        if (context.Users.Any())
        {
            return;
        }

        var random = new Random(42); // Fixed seed for consistent data

        // 1. Seed Users (100 total: 3 Admins, 40 Students, 40 Staff, 17 Visitors)
        var users = new List<User>();

        // User 1: Admin User 1 (ID = 1)
        users.Add(new User
        {
            Name = "Admin User 1",
            Email = "admin1@campus.edu",
            Role = UserRole.Admin,
            Status = UserStatus.Active,
            JoinedAt = DateTime.UtcNow.AddDays(-180),
        });

        // User 2: John Student (ID = 2)
        users.Add(new User
        {
            Name = "John Student",
            Email = "john@student.edu",
            Role = UserRole.Student,
            Status = UserStatus.Active,
            JoinedAt = DateTime.UtcNow.AddDays(-90),
        });

        // User 3: Admin User 2 (ID = 3)
        users.Add(new User
        {
            Name = "Admin User 2",
            Email = "admin2@campus.edu",
            Role = UserRole.Admin,
            Status = UserStatus.Active,
            JoinedAt = DateTime.UtcNow.AddDays(-120),
        });

        // User 4: Admin User 3 (ID = 4)
        users.Add(new User
        {
            Name = "Admin User 3",
            Email = "admin3@campus.edu",
            Role = UserRole.Admin,
            Status = UserStatus.Active,
            JoinedAt = DateTime.UtcNow.AddDays(-150),
        });

        // 39 other Students
        for (int i = 1; i <= 39; i++)
        {
            users.Add(new User
            {
                Name = $"Student User {i}",
                Email = $"student{i}@student.edu",
                Role = UserRole.Student,
                Status = UserStatus.Active,
                JoinedAt = DateTime.UtcNow.AddDays(-random.Next(30, 365)),
            });
        }

        // 40 Staff
        for (int i = 1; i <= 40; i++)
        {
            users.Add(new User
            {
                Name = $"Staff User {i}",
                Email = $"staff{i}@staff.edu",
                Role = UserRole.Staff,
                Status = UserStatus.Active,
                JoinedAt = DateTime.UtcNow.AddDays(-random.Next(30, 365)),
            });
        }

        // 17 Visitors
        for (int i = 1; i <= 17; i++)
        {
            users.Add(new User
            {
                Name = $"Visitor User {i}",
                Email = $"visitor{i}@visitor.edu",
                Role = UserRole.Visitor,
                Status = UserStatus.Active,
                JoinedAt = DateTime.UtcNow.AddDays(-random.Next(30, 365)),
            });
        }

        context.Users.AddRange(users);
        context.SaveChanges(); // Need IDs for foreign keys

        // 3. Seed Zones (Unified Manual Merged Polygons from Official API)
        var p1Zone = new Zone
        {
            Name = "P1 - Multi Level Parking",
            Capacity = 450,
            PricePerHour = 4.00,
            MaxDuration = 10,
            AccessLevel = AccessLevel.Staff,
            ZoneType = ZoneType.EV,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.878005, -34.407659], [150.878604, -34.407742], [150.878655, -34.407442], [150.878059, -34.407365], [150.878005, -34.407659]]]}",
        };

        var p2Zone = new Zone
        {
            Name = "P2 - Main Car Park",
            Capacity = 200,
            PricePerHour = 2.00,
            MaxDuration = 8,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.877957, -34.406783], [150.87777, -34.406763], [150.877662, -34.406753], [150.877337, -34.406712], [150.877269, -34.406706], [150.87721, -34.40702], [150.877553, -34.407328], [150.877739, -34.407468], [150.877838, -34.407515], [150.877957, -34.406783]]]}",
        };

        var p3Zone = new Zone
        {
            Name = "P3 - South Western Carpark",
            Capacity = 120,
            PricePerHour = 2.00,
            MaxDuration = 6,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.873886, -34.405726], [150.87456, -34.405811], [150.874802, -34.405909], [150.875027, -34.406037], [150.875181, -34.406153], [150.874541, -34.406548], [150.873728, -34.406428], [150.873792, -34.406118], [150.873819, -34.405992], [150.873886, -34.405726]]]}",
        };

        var p4Zone = new Zone
        {
            Name = "P4 - Western Carpark",
            Capacity = 80,
            PricePerHour = 0.00,
            MaxDuration = 8,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.873009, -34.40328], [150.87482, -34.403497], [150.874747, -34.40396], [150.874714, -34.404199], [150.874446, -34.404172], [150.874371, -34.404695], [150.874092, -34.404659], [150.874081, -34.404482], [150.87317, -34.404367], [150.872944, -34.403969], [150.872955, -34.403721], [150.873009, -34.40328]]]}",
        };

        var p5Zone = new Zone
        {
            Name = "P5 - Northern Carpark",
            Capacity = 60,
            PricePerHour = 2.00,
            MaxDuration = 4,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.877518, -34.401721], [150.878, -34.401778], [150.877873, -34.402447], [150.878385, -34.402526], [150.878736, -34.402796], [150.878545, -34.403856], [150.877633, -34.40373], [150.87637, -34.403598], [150.876452, -34.403477], [150.876645, -34.403502], [150.876704, -34.403404], [150.877027, -34.403343], [150.877221, -34.403332], [150.877251, -34.403051], [150.877486, -34.401833], [150.877518, -34.401721]]]}",
        };

        var p6Zone = new Zone
        {
            Name = "P6 - Sports Hub",
            Capacity = 30,
            PricePerHour = 5.00,
            MaxDuration = 2,
            AccessLevel = AccessLevel.Visitor,
            ZoneType = ZoneType.EV,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.879537, -34.403047], [150.879453, -34.403531], [150.880248, -34.403613], [150.880324, -34.403142], [150.879537, -34.403047]]]}",
        };

        var p8Zone = new Zone
        {
            Name = "P8 - Unicentre Carpark",
            Capacity = 150,
            PricePerHour = 3.50,
            MaxDuration = 4,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.EV,
            Status = ZoneStatus.Active,
            GeoJson =
                "{\"type\": \"Polygon\", \"coordinates\": [[[150.880614, -34.407523], [150.881725, -34.407642], [150.881687, -34.407979], [150.881641, -34.408267], [150.880452, -34.408132], [150.880494, -34.407851], [150.880509, -34.407849], [150.880529, -34.407762], [150.880578, -34.407721], [150.880614, -34.407523]]]}",
        };

        context.Zones.AddRange(p1Zone, p2Zone, p3Zone, p4Zone, p5Zone, p6Zone, p8Zone);
        context.SaveChanges();

        // 4. Seed Spots (Auto-Generate based on Capacity)
        var allSpots = new List<ParkingSpot>();

        void AddSpots(Zone zone, string prefix)
        {
            for (int i = 1; i <= zone.Capacity; i++)
            {
                allSpots.Add(
                    new ParkingSpot
                    {
                        SpotNumber = $"{prefix}-{i:D3}",
                        Status = SpotStatus.Available,
                        ZoneID = zone.ZoneID,
                    }
                );
            }
        }

        AddSpots(p1Zone, "P1");
        AddSpots(p2Zone, "P2");
        AddSpots(p3Zone, "P3");
        AddSpots(p4Zone, "P4");
        AddSpots(p5Zone, "P5");
        AddSpots(p6Zone, "P6");
        AddSpots(p8Zone, "P8");

        context.ParkingSpots.AddRange(allSpots);
        context.SaveChanges();

        // 4. Seed Vehicles (100 total, with 2 vehicles specifically for John Student)
        var nonAdminUsers = users.Where(u => u.Role != UserRole.Admin).ToList();
        var john = users.First(u => u.Email == "john@student.edu");
        var vehicles = new List<Vehicle>();

        // John Student's vehicles (2 vehicles)
        var johnVehicles = new List<Vehicle>
        {
            new Vehicle { LicensePlate = "JOHN-001", UserID = john.UserID },
            new Vehicle { LicensePlate = "JOHN-002", UserID = john.UserID }
        };
        vehicles.AddRange(johnVehicles);
        foreach (var v in johnVehicles)
        {
            john.Vehicles.Add(v);
        }

        // 98 vehicles for other non-admins
        var otherNonAdminUsers = nonAdminUsers.Where(u => u.UserID != john.UserID).ToList();
        for (int i = 1; i <= 98; i++)
        {
            var user = otherNonAdminUsers[(i - 1) % otherNonAdminUsers.Count];
            var vehicle = new Vehicle
            {
                LicensePlate = $"PARK-{i:D3}",
                UserID = user.UserID,
            };
            vehicles.Add(vehicle);
            user.Vehicles.Add(vehicle);
        }

        context.Vehicles.AddRange(vehicles);
        context.SaveChanges();

        // 5. Seed Bookings & Payments
        var bookings = new List<Booking>();

        // A. 130 Bookings for John Student
        for (int i = 1; i <= 130; i++)
        {
            var spot = allSpots[random.Next(allSpots.Count)];
            BookingStatus status;
            DateTime start, end;

            if (i <= 50)
            {
                status = BookingStatus.Past;
                start = DateTime.UtcNow.AddDays(-random.Next(1, 30)).AddHours(-random.Next(1, 12));
                end = start.AddHours(random.Next(1, 6));
            }
            else if (i <= 100)
            {
                status = BookingStatus.Upcoming;
                start = DateTime.UtcNow.AddDays(random.Next(1, 30)).AddHours(random.Next(1, 12));
                end = start.AddHours(random.Next(1, 6));
            }
            else
            {
                status = BookingStatus.Cancelled;
                start = DateTime.UtcNow.AddDays(random.Next(-15, 15)).AddHours(random.Next(1, 12));
                end = start.AddHours(random.Next(1, 6));
            }

            bookings.Add(new Booking
            {
                StartTime = start,
                EndTime = end,
                Status = status,
                UserID = john.UserID,
                SpotID = spot.SpotID,
                VehicleID = johnVehicles[(i - 1) % johnVehicles.Count].VehicleID,
            });
        }

        // B. 130 Bookings for other users
        for (int i = 1; i <= 130; i++)
        {
            var user = otherNonAdminUsers[random.Next(otherNonAdminUsers.Count)];
            var vehicle = user.Vehicles.First();
            var spot = allSpots[random.Next(allSpots.Count)];

            BookingStatus status;
            DateTime start, end;

            if (i <= 50)
            {
                status = BookingStatus.Past;
                start = DateTime.UtcNow.AddDays(-random.Next(1, 30)).AddHours(-random.Next(1, 12));
                end = start.AddHours(random.Next(1, 6));
            }
            else if (i <= 100)
            {
                status = BookingStatus.Upcoming;
                start = DateTime.UtcNow.AddDays(random.Next(1, 30)).AddHours(random.Next(1, 12));
                end = start.AddHours(random.Next(1, 6));
            }
            else
            {
                status = BookingStatus.Cancelled;
                start = DateTime.UtcNow.AddDays(random.Next(-15, 15)).AddHours(random.Next(1, 12));
                end = start.AddHours(random.Next(1, 6));
            }

            bookings.Add(new Booking
            {
                StartTime = start,
                EndTime = end,
                Status = status,
                UserID = user.UserID,
                SpotID = spot.SpotID,
                VehicleID = vehicle.VehicleID,
            });
        }

        context.Bookings.AddRange(bookings);
        context.SaveChanges();

        // Seed Payments
        var payments = new List<Payment>();

        // A. 100 Payments for John Student (first 100 non-cancelled bookings of John)
        var johnBookings = bookings.Where(b => b.UserID == john.UserID && b.Status != BookingStatus.Cancelled).Take(100).ToList();
        for (int i = 0; i < johnBookings.Count; i++)
        {
            var b = johnBookings[i];
            payments.Add(new Payment
            {
                Amount = 5.00 + random.Next(0, 10),
                Method = random.NextDouble() > 0.5 ? "card" : "mobile",
                Status = b.Status == BookingStatus.Past || random.NextDouble() > 0.2 ? PaymentStatus.Paid : PaymentStatus.Pending,
                PaidAt = b.StartTime.AddMinutes(-5),
                BookingID = b.BookingID,
            });
        }

        // B. 100 Payments for other users
        var otherBookings = bookings.Where(b => b.UserID != john.UserID && b.Status != BookingStatus.Cancelled).Take(100).ToList();
        for (int i = 0; i < otherBookings.Count; i++)
        {
            var b = otherBookings[i];
            payments.Add(new Payment
            {
                Amount = 5.00 + random.Next(0, 10),
                Method = random.NextDouble() > 0.5 ? "card" : "mobile",
                Status = b.Status == BookingStatus.Past || random.NextDouble() > 0.2 ? PaymentStatus.Paid : PaymentStatus.Pending,
                PaidAt = b.StartTime.AddMinutes(-5),
                BookingID = b.BookingID,
            });
        }

        context.Payments.AddRange(payments);
        context.SaveChanges();

        // 6. Seed Active Parking Sessions
        var activeSessions = new List<ParkingSession>();
        var activeSpots = allSpots.OrderBy(s => random.Next()).Take(30).ToList();

        // John Student's active session
        var johnActiveSpot = activeSpots[0];
        activeSessions.Add(new ParkingSession
        {
            StartTime = DateTime.UtcNow.AddMinutes(-random.Next(10, 120)),
            EndTime = null,
            Status = "Active",
            UserID = john.UserID,
            SpotID = johnActiveSpot.SpotID,
            VehicleID = johnVehicles[0].VehicleID,
        });
        johnActiveSpot.Status = SpotStatus.Occupied;

        // 15 active sessions for other users
        for (int i = 1; i <= 15; i++)
        {
            var user = otherNonAdminUsers[random.Next(otherNonAdminUsers.Count)];
            var vehicle = user.Vehicles.First();
            var spot = activeSpots[i];

            activeSessions.Add(new ParkingSession
            {
                StartTime = DateTime.UtcNow.AddMinutes(-random.Next(10, 240)),
                EndTime = null,
                Status = "Active",
                UserID = user.UserID,
                SpotID = spot.SpotID,
                VehicleID = vehicle.VehicleID,
            });

            spot.Status = SpotStatus.Occupied;
        }

        context.ParkingSessions.AddRange(activeSessions);
        context.SaveChanges();

        // 7. Seed Completed Parking Sessions for John (99 completed sessions)
        var johnCompletedSessions = new List<ParkingSession>();
        for (int i = 1; i <= 99; i++)
        {
            var spot = allSpots[random.Next(allSpots.Count)];
            var start = DateTime.UtcNow.AddDays(-random.Next(1, 30)).AddHours(-random.Next(1, 12));
            var end = start.AddHours(random.Next(1, 4));

            johnCompletedSessions.Add(new ParkingSession
            {
                StartTime = start,
                EndTime = end,
                Status = "Completed",
                UserID = john.UserID,
                SpotID = spot.SpotID,
                VehicleID = johnVehicles[(i - 1) % johnVehicles.Count].VehicleID,
            });
        }
        context.ParkingSessions.AddRange(johnCompletedSessions);
        context.SaveChanges();

        // 8. Generate Ghost History (Completed Sessions for other users)
        GenerateGhostHistory(context, allSpots, otherNonAdminUsers);
        context.SaveChanges();

        // 9. Seed Violations
        var violations = new List<Violation>();
        var allSessions = context.ParkingSessions.ToList();

        // A. 100 Violations for John Student
        var johnSessions = allSessions.Where(s => s.UserID == john.UserID).ToList();
        for (int i = 1; i <= 100; i++)
        {
            ParkingSession? session = null;
            if (johnSessions.Count > 0 && random.NextDouble() > 0.2)
            {
                session = johnSessions[random.Next(johnSessions.Count)];
            }

            violations.Add(new Violation
            {
                Type = (ViolationType)random.Next(0, 3),
                DetectedAt = session?.StartTime.AddHours(1) ?? DateTime.UtcNow.AddDays(-random.Next(1, 30)),
                Status = (ViolationStatus)random.Next(0, 3),
                SessionID = session?.SessionID,
                UserID = john.UserID,
            });
        }

        // B. 100 Violations for other users
        var otherSessions = allSessions.Where(s => s.UserID != john.UserID).ToList();
        for (int i = 1; i <= 100; i++)
        {
            var user = otherNonAdminUsers[random.Next(otherNonAdminUsers.Count)];
            ParkingSession? session = null;
            var userSessions = otherSessions.Where(s => s.UserID == user.UserID).ToList();

            if (userSessions.Count > 0 && random.NextDouble() > 0.2)
            {
                session = userSessions[random.Next(userSessions.Count)];
            }

            violations.Add(new Violation
            {
                Type = (ViolationType)random.Next(0, 3),
                DetectedAt = session?.StartTime.AddHours(1) ?? DateTime.UtcNow.AddDays(-random.Next(1, 30)),
                Status = (ViolationStatus)random.Next(0, 3),
                SessionID = session?.SessionID,
                UserID = user.UserID,
            });
        }

        context.Violations.AddRange(violations);
        context.SaveChanges();

        // 10. Seed Notifications
        var notifications = new List<Notification>();
        var notificationTypes = new[] { "booking_confirmation", "violation_alert", "payment_received" };
        var channels = new[] { "email", "sms", "push" };

        // A. 1 Notification for John Student
        notifications.Add(new Notification
        {
            Type = "booking_confirmation",
            Message = "Your booking has been confirmed.",
            Channel = "email",
            SentAt = DateTime.UtcNow.AddDays(-random.Next(1, 30)),
            UserID = john.UserID,
        });

        // B. 100 Notifications for other users
        for (int i = 1; i <= 100; i++)
        {
            var user = otherNonAdminUsers[random.Next(otherNonAdminUsers.Count)];
            var type = notificationTypes[random.Next(notificationTypes.Length)];
            var channel = channels[random.Next(channels.Length)];
            var msg = type switch
            {
                "booking_confirmation" => "Your booking has been confirmed.",
                "violation_alert" => "A parking violation has been detected for your vehicle.",
                "payment_received" => "Payment of $5.00 has been successfully processed.",
                _ => "Notification message",
            };

            notifications.Add(new Notification
            {
                Type = type,
                Message = msg,
                Channel = channel,
                SentAt = DateTime.UtcNow.AddDays(-random.Next(1, 30)),
                UserID = user.UserID,
            });
        }

        context.Notifications.AddRange(notifications);
        context.SaveChanges();
    }

    private static void GenerateGhostHistory(
        AppDbContext context,
        List<ParkingSpot> spots,
        List<User> nonAdminUsers
    )
    {
        var random = new Random(42); // Fixed seed for consistent "ghost" data
        var now = DateTime.UtcNow;
        var sessions = new List<ParkingSession>();

        foreach (var spot in spots)
        {
            // Seed ~15% of spots for high-density simulation but controlled data size
            if (random.NextDouble() > 0.15)
                continue;

            var zonePrefix = spot.SpotNumber.Split('-')[0];

            for (int day = 0; day <= 30; day++)
            {
                var date = now.Date.AddDays(-day);

                // Traffic Profile: Peak hour + multiple turnovers
                int peakStart = zonePrefix switch
                {
                    "P1" or "P2" => 7,
                    "P6" or "P8" => 11,
                    _ => 9,
                };

                var currentTime = date.AddHours(peakStart).AddMinutes(random.Next(0, 60));
                int turnovers = random.Next(1, 4); // 1 to 3 cars per spot per day

                for (int t = 0; t < turnovers; t++)
                {
                    int durationHours = random.Next(1, 4);
                    var endTime = currentTime.AddHours(durationHours);

                    if (endTime.Day != date.Day)
                        break; // Don't bleed into next day

                    var user = nonAdminUsers[random.Next(nonAdminUsers.Count)];
                    var vehicle = user.Vehicles.First();

                    sessions.Add(
                        new ParkingSession
                        {
                            SpotID = spot.SpotID,
                            UserID = user.UserID,
                            VehicleID = vehicle.VehicleID,
                            StartTime = currentTime,
                            EndTime = endTime,
                            Status = "Completed",
                        }
                    );

                    // Add a gap before the next car arrives
                    currentTime = endTime.AddMinutes(random.Next(15, 60));
                }
            }
        }

        context.ParkingSessions.AddRange(sessions);
    }
}
