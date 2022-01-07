unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JNI, JNIUtils;

type
  TForm1 = class(TForm)
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FJavaVM : TJavaVM;
    FJavaEnv: TJNIEnv;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  Options: array [0 .. 4] of JavaVMOption;
  VM_args: JavaVMInitArgs;
  ErrCode: Integer;
begin
  { ���� Java ����� }
  FJavaVM                    := TJavaVM.Create(JNI_VERSION_1_8, ExtractFilePath(ParamStr(0)) + 'jre1.8.0_202\bin\client\jvm.dll');
  Options[0].optionString    := PAnsiChar(AnsiString('-Djava.class.path=' + ExtractFilePath(ParamStr(0)) + 'classes'));
  VM_args.version            := JNI_VERSION_1_8;
  VM_args.Options            := @Options;
  VM_args.nOptions           := 1;
  VM_args.ignoreUnrecognized := True;
  ErrCode                    := FJavaVM.LoadVM(VM_args);
  if ErrCode < 0 then
  begin
    MessageBox(Handle, 'Create Java VM Error', 'Delphi 11 ���� Java Class', MB_OK OR MB_ICONERROR);
    Halt;
    Exit;
  end;

  { ���� Java ��������л��� }
  FJavaEnv := TJNIEnv.Create(FJavaVM.Env);
  if FJavaEnv = nil then
  begin
    MessageBox(Handle, 'Create Java Env Error', 'Delphi 11 ���� Java Class', MB_OK OR MB_ICONERROR);
    Exit;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FJavaEnv.Free;
  FJavaVM.DestroyJavaVM;
  FJavaVM.Free;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  jcls             : JClass;
  strClass         : UTF8String;
  strMetod         : UTF8String;
  strSign          : UTF8String;
  strArg, strResult: string;
begin
  { ��ѯ Java ���� }
  strClass := 'com/test/javafordelphi/JavaClassForDelphiTest';
  jcls     := FJavaEnv.FindClass(strClass);
  if jcls = nil then
  begin
    MessageBox(Handle, 'cant find java class', 'Delphi 11 ���� Java Class', MB_OK OR MB_ICONERROR);
    Exit;
  end;

  { Java �������ơ��������͡����� }
  strMetod := 'goTest';          // ��������
  strSign  := 'String (String)'; // �������ͣ�����ֵ����
  strArg   := '123';             // �������

  { ִ�� Java ���� }
  strResult := CallMethod(FJavaEnv, jcls, strMetod, strSign, [strArg], True);
  if strResult <> '' then
  begin
    MessageBox(Handle, PChar(Format('JavaClassForDelphiTest.goTest  Result: %s', [strResult])), 'Delphi 11 ���� Java Class', MB_OK OR MB_ICONINFORMATION);
  end;
end;

end.
