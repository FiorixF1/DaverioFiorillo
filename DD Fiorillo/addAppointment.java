// inside class Manager
public void addAppointment(User user, Appointment app) {
    Calendar cal = user.getCalendar();
    DateTime begin = app.getBeginTime();
    DateTime end = app.getEndTime();
    
    if (checkOverlapping(cal, app, begin, end)) {
        cal.insertAppointment(app);
    } else {
        throw new OverlappingException();
    }
}