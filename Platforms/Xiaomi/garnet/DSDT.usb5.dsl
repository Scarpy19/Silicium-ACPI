/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 *
 * Disassembly of DSDT.aml
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x00000162 (354)
 *     Revision         0x02
 *     Checksum         0xE5
 *     OEM ID           "QCOMM "
 *     OEM Table ID     "SM8250 "
 *     OEM Revision     0x00000003 (3)
 *     Compiler ID      "MSFT"
 *     Compiler Version 0x05000000 (83886080)
 *
 * Prepared variant: DSDT.usb2.dsl + USB0 _DSM advertising only function 6
 * (return 1 = 32-bit register access). DSDT.aml / DSDT.dsl left untouched.
 */
DefinitionBlock ("", "DSDT", 2, "QCOMM ", "SM8250 ", 0x00000003)
{
    Scope (\_SB)
    {
        Device (CPU0)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU1)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU2)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU3)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU4)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU5)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU6)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x06)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (CPU7)
        {
            Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
            Name (_UID, 0x07)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        //
        // Minimal generic xHCI controller (prepared, not wired).
        // UEFI XhciPciEmulationDxe leaves the DWC3 core at 0x0A600000 in
        // host/xHCI mode; expose it directly so inbox USBXHCI can bind
        // without a Qualcomm URS/QUSB role-switch or PEP dependency.
        // DTS: ssusb@a600000 reg 0xa600000/0x100000 (garnet.dts:734-737);
        // dwc3@a600000 SPI 0x85=133 -> GSIV 165, level-high (garnet.dts:758-766);
        // dma-coherent -> _CCA=1 (garnet.dts:764).
        //
        Device (USB0)
        {
            Name (_HID, "PNP0D10")  // Generic xHCI host controller
            Name (_CID, "PNP0D15")  // Secondary xHCI PNP ID
            Name (_UID, Zero)
            Name (_CCA, Zero)  // _CCA=0: non-coherent DMA (as working Qcom ports); test vs DTS dma-coherent
            Name (_STA, 0x0F)  // _STA: Status
            //
            // Power-keep hints: no Qualcomm PEP, no _DEP dependency.
            // _S0W=0 declares D0 as the deepest wake-capable state in S0,
            // i.e. no D3 while S0. Kept truthful to D0 wake support.
            // No _PR0/_PR3 and no _PS0/_PS3: unverified GDSC/PHY sequencing
            // is not fabricated in AML; rails/clocks stay firmware-owned
            // (DESIGN_USB_POWER_NO_PEP.md sec.1/C).
            // No _DSD and no _DSW: neither is a documented D0 policy switch
            // for this inbox stack; wake arming is not a D-state ban.
            //
            Name (_S0W, Zero)  // _S0W: deepest S0 wake state = D0
            Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
            {
                Memory32Fixed (ReadWrite, 0x0A600000, 0x00100000)
                Interrupt (ResourceConsumer, Level, ActiveHigh, Exclusive) { 165 }
            })
            //
            // Microsoft USB _DSM (UUID ce2ee385-...). Function 6 returns 1 to
            // force 32-bit register access; bitmap 0x41 advertises only
            // functions 0 (query) and 6. No MMIO, no reset, no PEP calls.
            // Revision 0; all other functions return an empty-buffer bitmap.
            //
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg0, ToUUID ("ce2ee385-00e6-48cb-9f05-2edb927c4899")))
                {
                    If (LGreaterEqual (Arg1, Zero)) // any revision
                    {
                        If (LEqual (Arg2, Zero)) { Return (Buffer (One) { 0x41 }) }
                        If (LEqual (Arg2, 0x06)) { Return (One) }
                    }
                }
                Return (Buffer (One) { 0x00 })
            }
        }
    }
}
