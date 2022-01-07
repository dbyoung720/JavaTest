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
  { 创建 Java 虚拟机 }
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
      Writeln('创建 Java 虚拟机 失败');
      Exit;
    end;

    { 创建 Java 虚拟机运行环境 }
    jEnv := TJNIEnv.Create(jVM.Env);
    try
      if jEnv = nil then
      begin
        Writeln('创建 Java 虚拟机运行环境 失败');
        Exit;
      end;

      { 获取 Java 类 }
      strClass := 'Prog';
      cls      := jEnv.FindClass(strClass);
      if cls = nil then
      begin
        Writeln('没有找到类名');
        Exit;
      end;

      { 获取 Java 类的函数对象 }
      mid := jEnv.GetStaticMethodID(cls, 'main', '([Ljava/lang/String;)V');

      { 输入 Java 函数的参数类型、参数 }
      stringClass := jEnv.FindClass('java/lang/String');
      jstr        := jEnv.NewStringUTF(' from Delphi 11');
      args        := jEnv.NewObjectArray(1, stringClass, jstr);

      { 执行 Java 函数 }
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
