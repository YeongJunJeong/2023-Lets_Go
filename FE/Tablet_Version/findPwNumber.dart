/*
SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "휴대폰 번호",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPhoneVerificationCode,
              child: Text("휴대폰으로 인증코드 보내기"),
            ),
            if (_isPhoneSent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      labelText: "인증 코드",
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _verifyCode(
                          _verificationCodeController.text, _phoneVerificationCode);
                    },
                    child: Text("인증하기"),
                  ),
                ],
              ),
            if (_isCodeVerified)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: AlertDialog(
                  title: Text("계정 정보를 보냈습니다!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("확인"),
                    ),
                  ],
                ),
              ),
*/