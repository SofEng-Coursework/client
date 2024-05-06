import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/controllers/userAccountController.dart';
import 'package:virtual_queue/pages/userDashboard.dart';

class AccountDetailsEditWidget extends StatelessWidget {
  AccountDetailsEditWidget({
    required this.accountController,
    super.key,
  });

  final AccountController accountController;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 30),
      color: Color(0xffffffff),
      shadowColor: Color(0xffd5d2d2),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Account Details",
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextField(
                controller: nameController,
                obscureText: false,
                textAlign: TextAlign.start,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Color(0xff000000), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Color(0xff000000), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Color(0xff000000), width: 1),
                  ),
                  labelText: "Name",
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                  hintText: "Enter Name",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                  filled: true,
                  fillColor: Color(0xfff2f2f3),
                  isDense: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            ),
            Divider(
              color: Color(0xff808080),
              height: 16,
              thickness: 0.3,
              indent: 0,
              endIndent: 0,
            ),
            TextField(
              controller: phoneNumberController,
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14,
                color: Color(0xff000000),
              ),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Color(0xff000000), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Color(0xff000000), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Color(0xff000000), width: 1),
                ),
                labelText: "Phone Number",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                hintText: "Enter Phone Number",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                filled: true,
                fillColor: Color(0xfff2f2f3),
                isDense: false,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                  onPressed: () {
                    accountController
                        .updateAccount(
                      name: nameController.text.isNotEmpty ? nameController.text : null,
                      phone: phoneNumberController.text.isNotEmpty ? phoneNumberController.text : null,
                    )
                        .then((errorStatus) {
                      if (errorStatus.success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Account details updated successfully"),
                          duration: Duration(seconds: 2),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("An error occurred: ${errorStatus.message}"),
                          duration: Duration(seconds: 2),
                        ));
                      }
                    });
                  },
                  child: Text("Save Changes")),
            )
          ],
        ),
      ),
    );
  }
}

class NotificationToggleWidget extends StatelessWidget {
  const NotificationToggleWidget({
    required this.accountController,
    super.key,
  });

  final UserAccountController accountController;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16, 30, 16, 0),
      color: Color(0xffffffff),
      shadowColor: Color(0xffd5d2d2),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Notification Settings",
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xff000000),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: SwitchListTile(
                value: accountController.pushNotificationEnabled,
                onChanged: (value) {
                  accountController.togglePushNotification(value);
                },
                title: Text(
                  "Push Notification",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                  textAlign: TextAlign.start,
                ),
                subtitle: Text(
                  "Receive weekly push notification",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12,
                    color: Color(0xff737070),
                  ),
                  textAlign: TextAlign.start,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                tileColor: Color(0x00ffffff),
                activeColor: Color(0xff017a08),
                activeTrackColor: Color(0x41017a08),
                controlAffinity: ListTileControlAffinity.trailing,
                dense: false,
                inactiveThumbColor: Color(0xff9e9e9e),
                inactiveTrackColor: Color(0xffe0e0e0),
                contentPadding: EdgeInsets.all(0),
                selected: false,
                selectedTileColor: Color(0x42000000),
              ),
            ),
            Divider(
              color: Color(0xff808080),
              height: 16,
              thickness: 0.3,
              indent: 0,
              endIndent: 0,
            ),
            SwitchListTile(
              value: true,
              title: Text(
                "Chat Notification",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                textAlign: TextAlign.start,
              ),
              subtitle: Text(
                "Receive chat notification",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12,
                  color: Color(0xff737070),
                ),
                textAlign: TextAlign.start,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              onChanged: (value) {},
              tileColor: Color(0x00ffffff),
              activeColor: Color(0xff017a08),
              activeTrackColor: Color(0x41017a08),
              controlAffinity: ListTileControlAffinity.trailing,
              dense: false,
              inactiveThumbColor: Color(0xff9e9e9e),
              inactiveTrackColor: Color(0xffe0e0e0),
              contentPadding: EdgeInsets.all(0),
              selected: false,
              selectedTileColor: Color(0x42000000),
            ),
            Divider(
              color: Color(0xff808080),
              height: 16,
              thickness: 0.3,
              indent: 0,
              endIndent: 0,
            ),
            SwitchListTile(
              value: false,
              title: Text(
                "Email Notification",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                textAlign: TextAlign.start,
              ),
              subtitle: Text(
                "Receive email notification",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12,
                  color: Color(0xff737070),
                ),
                textAlign: TextAlign.start,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              onChanged: (value) {},
              tileColor: Color(0x00ffffff),
              activeColor: Color(0xff3a57e8),
              activeTrackColor: Color(0x3f3a57e8),
              controlAffinity: ListTileControlAffinity.trailing,
              dense: false,
              inactiveThumbColor: Color(0xff9e9e9e),
              inactiveTrackColor: Color(0xffe0e0e0),
              contentPadding: EdgeInsets.all(0),
              selected: false,
              selectedTileColor: Color(0x42000000),
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({
    required this.accountController,
    super.key,
  });

  final AccountController accountController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: MaterialButton(
        onPressed: () {
          accountController.signOut();
          Navigator.of(context).pop();
        },
        color: Color(0xff017a08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.all(16),
        textColor: Color(0xffffffff),
        height: 50,
        minWidth: MediaQuery.of(context).size.width,
        child: const Text(
          "Logout",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({
    required this.accountController,
    super.key,
  });

  final AccountController accountController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: MaterialButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Delete Account"),
                  content: Text("Are you sure you want to delete your account?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        accountController.deleteAccount();
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(); // Close the settings page
                      },
                      child: Text("Delete"),
                    ),
                  ],
                );
              });
        },
        color: Color.fromARGB(255, 122, 1, 1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.all(16),
        textColor: Color(0xffffffff),
        height: 50,
        minWidth: MediaQuery.of(context).size.width,
        child: const Text(
          "Delete Account",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
