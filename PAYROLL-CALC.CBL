       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYROLL-CALC.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-EMP-RECORD.
          05 WS-EMP-ID        PIC X(10).
          05 WS-BASE-SALARY   PIC 9(6)V99.
          05 WS-HOURS-WORKED  PIC 9(3)V99.
          05 WS-TAX-TIER      PIC 9(1).

       01 WS-CALC-FIELDS.
          05 WS-OVERTIME-HRS  PIC 9(3)V99 VALUE ZERO.
          05 WS-GROSS-PAY     PIC 9(7)V99 VALUE ZERO.
          05 WS-TAX-DEDUCT    PIC 9(6)V99 VALUE ZERO.
          05 WS-NET-PAY       PIC 9(7)V99 VALUE ZERO.

       PROCEDURE DIVISION.

       0100-CALC-PAY.

           IF WS-HOURS-WORKED > 40.00

               COMPUTE WS-OVERTIME-HRS =
                   WS-HOURS-WORKED - 40.00

               COMPUTE WS-GROSS-PAY =
                   (40.00 * (WS-BASE-SALARY / 40.00))
                   + (WS-OVERTIME-HRS
                   * (WS-BASE-SALARY / 40.00)
                   * 1.5)

           ELSE

               COMPUTE WS-GROSS-PAY =
                   WS-HOURS-WORKED
                   * (WS-BASE-SALARY / 40.00)

           END-IF.

           EVALUATE WS-TAX-TIER

               WHEN 1
                   COMPUTE WS-TAX-DEDUCT =
                       WS-GROSS-PAY * 0.10

               WHEN 2
                   COMPUTE WS-TAX-DEDUCT =
                       WS-GROSS-PAY * 0.20

               WHEN 3
                   COMPUTE WS-TAX-DEDUCT =
                       WS-GROSS-PAY * 0.30

               WHEN OTHER
                   COMPUTE WS-TAX-DEDUCT =
                       WS-GROSS-PAY * 0.35

           END-EVALUATE.

           COMPUTE WS-NET-PAY =
               WS-GROSS-PAY - WS-TAX-DEDUCT.

           GOBACK.
