// inside class Manager
public void removeAppointment(User user, Appointment app) {
    // when removing an appointment, also the routes starting from or ending to it must be deleted
    app.removeAllRoutes();
    
    // then remove the appointment from the calendar
    cal.removeAppointment(app);
}