class SessionData {
  String? userEmail;
}

SessionData globalSessionData = SessionData();

//Having a clear function is pretty handy
void clearSessionData() {
  globalSessionData = new SessionData();
}
