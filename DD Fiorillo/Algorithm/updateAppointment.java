// inside class Manager
public void updateAppointment(User user, Appointment app, DateTime newBegin, DateTime newEnd, Position newPosition) {
    Calendar cal = user.getCalendar();
    DateTime oldBegin = app.getBeginTime();
    DateTime oldEnd = app.getEndTime();
    Position oldPosition = app.getPosition();
    
    // if starting or ending time or position changes, routes going to or coming from the appointment must be deleted
    if (!oldBegin.equals(newBegin) || !oldEnd.equals(newEnd) || !oldPosition.equals(newPosition)) {
        app.removeAllRoutes();
    }
    
    // then update with new attributes
    app.setBeginTime(newBegin);
    app.setEndTime(newEnd);
    app.setPosition(newPosition);
}