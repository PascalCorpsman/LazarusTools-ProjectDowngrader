Unit Unit1;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, udomxml;

Type

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private

  public
    Procedure Downgrade_lpi(Filename: String);

  End;

Var
  Form1: TForm1;

Implementation

{$R *.lfm}

Procedure FixCount(Const n: TDomNode; StartWithzero: Boolean);
Var
  i: integer;
  nn: TDomNode;
  prev: String;
  b: Boolean;
Begin
  // Sicherstellen, dass Count als Attribut existiert
  b := false;
  For i := 0 To n.AttributeCount - 1 Do Begin
    If n.Attribute[i].AttributeName = 'Count' Then Begin
      b := true;
      break;
    End;
  End;
  If Not b Then Begin
    n.AddAttribute('Count', '');
  End;
  // Bestimmen des Sibling Grundnamens
  i := 0;
  nn := n.FirstChild;
  If assigned(nn) Then Begin
    prev := nn.NodeName;
    If (length(prev) <> 0) And ((prev[length(prev)] = '0') Or (prev[length(prev)] = '1')) Then Begin
      prev := copy(prev, 1, length(prev) - 1);
    End;
  End;
  // Durchzählen aller Siblings
  While assigned(nn) Do Begin
    If StartWithzero Then Begin
      nn.NodeName := prev + inttostr(i);
    End
    Else Begin
      nn.NodeName := prev + inttostr(i + 1);
    End;
    inc(i);
    nn := n.NextSibling;
  End;
  n.AttributeValue['Count'] := inttostr(i);
End;

{ TForm1 }

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  If OpenDialog1.Execute Then Begin
    Downgrade_lpi(OpenDialog1.FileName);
  End;
End;

Procedure TForm1.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  caption := 'Lpi downgrader ver. 0.01';
  If FileExists(ParamStr(1)) Then Begin
    Downgrade_lpi(ParamStr(1));
    halt;
  End;
End;

Procedure TForm1.Downgrade_lpi(Filename: String);
Var
  n: TDomNode;
  xml: TDOMXML;
Begin
  xml := TDOMXML.Create;
  xml.LoadFromFile(FileName);
  xml.Indent := '  ';
  n := xml.DocumentElement.FindNode('Version');
  If assigned(n) Then Begin
    n.AttributeValue['Value'] := '11';
  End;

  n := xml.DocumentElement.FindNode('BuildModes');
  If assigned(n) Then Begin
    FixCount(n, false);
  End;

  n := xml.DocumentElement.FindNode('RequiredPackages');
  If assigned(n) Then Begin
    FixCount(n, false);
  End;

  n := xml.DocumentElement.FindNode('Units');
  If assigned(n) Then Begin
    FixCount(n, true);
  End;

  n := xml.DocumentElement.FindNode('Exceptions');
  If assigned(n) Then Begin
    FixCount(n, false);
  End;

  xml.SaveToFile(FileName);
  xml.Free;
  showmessage('Ready.');
End;

End.

