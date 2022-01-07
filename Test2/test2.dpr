program test2;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}
{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils, JNI, JNIUtils;

procedure Test;
var
  jVM        : TJavaVM;
  jEnv       : TJNIEnv;
  Options    : array [0 .. 0] of JavaVMOption;
  VM_args    : JavaVMInitArgs;
  ErrCode    : Integer;
  strClass   : UTF8String;
  cls        : JClass;
  jstr       : JObject;
  stringClass: JObject;
  args       : JObject;
  mid        : JMethodID;
begin
  { ���� Java ����� }
  jVM := TJavaVM.Create(JNI_VERSION_1_8, ExtractFilePath(ParamStr(0)) + 'jre1.8.0_202\bin\client\jvm.dll');
  try
    Options[0].optionString    := '-Djava.class.path=.';
    VM_args.version            := JNI_VERSION_1_2;
    VM_args.Options            := @Options;
    VM_args.nOptions           := 1;
    VM_args.ignoreUnrecognized := True;
    ErrCode                    := jVM.LoadVM(VM_args);
    if ErrCode < 0 then
    begin
      Writeln('���� Java ����� ʧ��');
      Exit;
    end;

    { ���� Java ��������л��� }
    jEnv := TJNIEnv.Create(jVM.Env);
    try
      if jEnv = nil then
      begin
        Writeln('���� Java ��������л��� ʧ��');
        Exit;
      end;

      { ��ȡ Java �� }
      strClass := 'Prog';
      cls      := jEnv.FindClass(strClass);
      if cls = nil then
      begin
        Writeln('û���ҵ�����');
        Exit;
      end;

      { ��ȡ Java ��ĺ������� }
      mid := jEnv.GetStaticMethodID(cls, 'main', '([Ljava/lang/String;)V');

      { ���� Java �����Ĳ������͡����� }
      stringClass := jEnv.FindClass('java/lang/String');
      jstr        := jEnv.NewStringUTF(' from Delphi 11');
      args        := jEnv.NewObjectArray(1, stringClass, jstr);

      { ִ�� Java ���� }
      jEnv.CallStaticVoidMethod(cls, mid, [args]);
    finally
      jEnv.Free;
    end;

  finally
    jVM.DestroyJavaVM;
    jVM.Free;
  end;
end;

begin
  try
    Test;
   // Readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;

end.
