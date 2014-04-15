import gdsl.BareFrontend;
import gdsl.Frontend;
import gdsl.Gdsl;
import gdsl.HeapExpiredException;
import gdsl.ResourceUnavailableException;
import gdsl.arch.ArchId;
import gdsl.decoder.Decoder;
import gdsl.decoder.Instruction;
import gdsl.rreil.DefaultRReilBuilder;
import gdsl.rreil.IRReilCollection;
import gdsl.rreil.statement.IStatement;
import gdsl.translator.SemPres;
import gdsl.translator.TranslatedBlock;
import gdsl.translator.Translator;

import java.nio.ByteBuffer;

import org.junit.Test;


public class GdslTest {
  private ByteBuffer buffer () {
    ByteBuffer buffer = ByteBuffer.allocateDirect(8);
    buffer.put((byte) 0);
    buffer.put((byte) 0);
    buffer.put((byte) 0);
    buffer.put((byte) 0);
    buffer.put((byte) 0xc3);

    buffer.put((byte) 0);
    buffer.put((byte) 0);
    buffer.put((byte) 0xc3);

    buffer.position(0);

    return buffer;
  }

  private Frontend frontendFromListEnv () {
    Frontend[] frontends = Gdsl.getFrontends();

    for (Frontend frontend : frontends)
      System.out.println("Frontend: " + frontend);

    return frontends[0];
  }

  private Frontend frontendFromListBase () {
    Frontend[] frontends = Gdsl.getFrontends("/home/jucs/projects/gdsl-toolkit/lib");

    for (Frontend frontend : frontends)
      System.out.println("Frontend: " + frontend);

    return frontends[0];
  }

  private Frontend frontend () {
    return new BareFrontend(ArchId.X86);
  }

  private void block (Gdsl gdsl) {
    Translator t = new Translator(gdsl, new DefaultRReilBuilder());
    TranslatedBlock b =
      t.translateOptimizeBlock(gdsl.getBuffer().limit() - gdsl.getBuffer().position(), SemPres.EVERYWHERE);
    System.out.println(b);
  }

  private void single (Gdsl gdsl) {
    Decoder decoder = new Decoder(gdsl);

    Instruction insn = decoder.decodeOne();

    System.out.println(insn);
    for (int i = 0; i < insn.operands(); i++) {
      System.out.println("\tOperand " + i + ": " + insn.operandToString(i));
      System.out.println("\tOperandType " + i + ": " + insn.operandType(i));
    }

    Translator t = new Translator(gdsl, new DefaultRReilBuilder());

    IRReilCollection<IStatement> rreil = t.translate(insn);
    System.out.println(rreil);
  }

  @Test public void testBlock () {
    System.out.println("testBlock()");
    Gdsl gdsl = new Gdsl(frontend());
    gdsl.setCode(buffer(), 0, 0);
    block(gdsl);
  }

  @Test public void testSingle () {
    System.out.println("testSingle()");

    Gdsl gdsl = new Gdsl(frontendFromListEnv());
    gdsl.setCode(buffer(), 0, 0);
    single(gdsl);
  }

  @Test public void testBlockSingleOneFrontend () {
    System.out.println("testBlockSingleOneFrontend()");

    Frontend f = frontendFromListBase();

    Gdsl gdslBlock = new Gdsl(f);
    gdslBlock.setCode(buffer(), 0, 0);
    block(gdslBlock);

    Gdsl gdslSingle = new Gdsl(f);
    gdslSingle.setCode(buffer(), 0, 0);
    single(gdslSingle);
  }

  @Test(expected = ResourceUnavailableException.class) public void testBlockDestroyHeap () {
    System.out.println("testBlockDestroyedFrontend()");

    Frontend f = frontendFromListBase();
    Gdsl gdslBlock = new Gdsl(f);

    f.free();

    gdslBlock.setCode(buffer(), 0, 0);

    Translator t = new Translator(gdslBlock, new DefaultRReilBuilder());
    TranslatedBlock b =
      t.translateOptimizeBlock(gdslBlock.getBuffer().limit() - gdslBlock.getBuffer().position(), SemPres.EVERYWHERE);

    System.out.println(b);
  }

  @Test(expected = HeapExpiredException.class) public void testBlockDestroyedHeap () {
    System.out.println("testBlockDestroyedGdsl()");

    Frontend f = frontendFromListBase();

    Gdsl gdslBlock = new Gdsl(f);
    gdslBlock.setCode(buffer(), 0, 0);

    Translator t = new Translator(gdslBlock, new DefaultRReilBuilder());
    TranslatedBlock b =
      t.translateOptimizeBlock(gdslBlock.getBuffer().limit() - gdslBlock.getBuffer().position(), SemPres.EVERYWHERE);

    gdslBlock.free();

    System.out.println(b);
  }

  @Test public void testLooping1 () {
    System.out.println("testLooping1()");
    for (int i = 0; i < 1000000; i++) {
      Frontend f = frontend();
      for (int j = 0; j < 10; j++) {
        Gdsl gdslBlock = new Gdsl(f);
        gdslBlock.setCode(buffer(), 0, 0);

        Translator t = new Translator(gdslBlock, new DefaultRReilBuilder());
        TranslatedBlock b =
          t.translateOptimizeBlock(gdslBlock.getBuffer().limit() - gdslBlock.getBuffer().position(), SemPres.EVERYWHERE);

        b.toString();
      }
      if (i % 1000 == 0)
        System.out.println("Outer " + i);
    }
  }

//  @Test public void testLooping2 () {
//    System.out.println("testLooping2()");
//    for (int i = 0; i < 10; i++) {
//      Frontend f = frontendFromListBase();
//      for (int j = 0; j < 1000000; j++) {
//        Gdsl gdslBlock = new Gdsl(f);
//        gdslBlock.setCode(buffer(), 0, 0);
//
//        Translator t = new Translator(gdslBlock, new DefaultRReilBuilder());
//        TranslatedBlock b =
//          t.translateOptimizeBlock(gdslBlock.getBuffer().limit() - gdslBlock.getBuffer().position(), SemPres.EVERYWHERE);
//
//        b.toString();
//      }
//      System.out.println("Outer " + i);
//    }
//  }

}